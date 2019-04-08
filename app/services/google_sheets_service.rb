require 'google/apis/sheets_v4'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = "urn:ietf:wg:oauth:2.0:oob"
APPLICATION_NAME = "Google Sheets API - Nucleo Website"
CLIENT_SECRETS_PATH = ENV["GOOGLE_SECRETS_PATH"]
CREDENTIALS_PATH = ENV["GOOGLE_CREDENTIALS_PATH"]
SCOPE = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY

module GoogleSheetsService
  class << self
    def read_spreadsheet(spreadsheet_id, range)
      credentials = GoogleSheetsService.authorize_google_sheets
      service = Google::Apis::SheetsV4::SheetsService.new
      service.client_options.application_name = APPLICATION_NAME
      service.authorization = credentials
  
      response = service.get_spreadsheet_values(spreadsheet_id, range)
      yield response.values
    end
  
    def authorize_google_sheets
      FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
  
      client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
      token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
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
end