require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = "urn:ietf:wg:oauth:2.0:oob"
APPLICATION_NAME = "Google Sheets API - Nucleo Website"
CLIENT_SECRETS_PATH = ENV["GOOGLE_SECRETS_PATH"]
CREDENTIALS_PATH = ENV["GOOGLE_CREDENTIALS_PATH"]
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

class WebhooksController < ApplicationController
  skip_before_action :set_locale
  skip_before_action :persist_locale
  skip_before_action :authenticate_user!
  skip_before_action :set_editor_config
  skip_before_action :set_localizable_page


  def social_links
    if params[:type] == "useful" || Time.new.wday == 1
      render_link_results send_sheets_links('1FfTqrjlh0Nkl3Hsr6AIriKMurFASmy-WjWFUhKC9yX4', 'Links!A2:C', :useful_links)
    elsif params[:type] == "comment" || Time.new.wday == 3
      render_link_results send_sheets_links('1BCfJUpRfZ4btuffTX_V2JhDC7lDL__wX57PEvmhzUW8', 'Links!A2:C', :comment_links)
    elsif params[:type] == "inspirational" || Time.new.wday == 5
      render_link_results send_sheets_links('1bIFRqyfG0XdlXlrrS7tF81RVfVXcwFQk6UcFMBttKiI', 'Links!A2:C', :inspirational_links)
    else
      render_link_results [], :ok
    end
  end

  def render_link_results(links, status = :ok)
    render json: { message: (links.count > 0 ? "mail sent" : "no mail sent") }, status: status
  end

  def send_sheets_links(spreadsheet_id, range, mail_method)
    credentials = authorize_google_sheets
    read_spreadsheet(credentials, spreadsheet_id, range) do |rows|
      links = !rows ? [] : rows.map do |row|
        link = Link.new
        link.name = row[0]
        link.url = row[1]
        link.date = row[2] if row.length > 2
        link
      end
      if links.length > 0
        spreadsheet_link = "https://docs.google.com/spreadsheets/d/#{spreadsheet_id}"
        SocialMailer.public_send(mail_method, spreadsheet_link, links).deliver
      else
        puts "NONE DELIVERED"
      end
      links
    end
  end

  def read_spreadsheet(credentials, spreadsheet_id, range)
    service = Google::Apis::SheetsV4::SheetsService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = credentials

    response = service.get_spreadsheet_values(spreadsheet_id, range)
    result = yield response.values
    result
  end

  def authorize_google_sheets
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))

    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      if ENV["GOOGLE_HAS_CONSOLE"]
        url = authorizer.get_authorization_url(
          base_url: OOB_URI)
        puts "Open the following URL in the browser and enter the resulting code after authorization #{url}"
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: OOB_URI)
      else
        throw "Open the following URL in the browser and enter the resulting code after authorization: #{url}"
      end
    end
    credentials
  end

end
