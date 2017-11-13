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

  def indexes
    if Time.new.wday == 1 || params[:force] == "1"
      sales_indexes = calculate_sales_indexes(Time.new, 2.month)
      execution_indexes = calculate_execution_indexes(Time.new, 2.month)

      send_indexes(sales_indexes + execution_indexes)
      render json: { message: "indexes sent" }, status: :ok
    else
      render json: { message: "no indexes sent, not today" }, status: :ok
    end
  end

  def calculate_sales_indexes(base_date, time_span)
    begin_date = base_date - time_span
    begin_date_str = begin_date.strftime("%Y-%m-%d")
    end_date = base_date + time_span
    end_date_str = end_date.strftime("%Y-%m-%d")

    data_field = 'Data'
    filter = "AND(OR(Status = 'Iniciado', Status = 'Enviado'), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
    filter_string = ERB::Util.u(filter)
    url = "https://api.airtable.com/v0/appdfAwtINoSYGqqD/Projetos?view=Grid%20view&filterByFormula=#{filter_string}"
    auth = "Bearer #{ENV['AIRTABLE_API']}"
    started = get_from_airtable(url)

    data_field = 'Data Aprovação'
    filter = "AND(Status = 'Aprovado', IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
    filter_string = ERB::Util.u(filter)
    url = "https://api.airtable.com/v0/appdfAwtINoSYGqqD/Projetos?view=Grid%20view&filterByFormula=#{filter_string}"
    auth = "Bearer #{ENV['AIRTABLE_API']}"
    approved = get_from_airtable(url)

    started_index = CompanyIndex.new
    started_index.name = "Índice Orçamentos"
    started_index.description = "Entre 50 e 100 MELHOR, menor significa poucos orçamentos, acima de 100 significam orçamentos atrapalhando a produtividade"
    started_index.value = (100.0 * started.count) / ENV["ESTIMATE_IDEAL_COUNT"].to_f
    # puts customer_happyness_index.to_json

    approved_index = CompanyIndex.new
    approved_index.name = "Índice Fechados"
    approved_index.description = "Entre 50 e 100 MELHOR, menor significa poucos projetos fechados, acima de 100 talvez signifique projetos demais fechados"
    approved_index.value = (100.0 * approved.count) / ENV["ORDER_IDEAL_COUNT"].to_f
    # puts hours_rate_index.to_json

    [started_index, approved_index]
  end

  def get_from_airtable(url)
    auth = "Bearer #{ENV['AIRTABLE_API']}"
    response = RestClient.get(url, {:Authorization => auth })
    JSON.parse(response)["records"]
  end

  def calculate_execution_indexes(base_date, time_span)
    now = base_date
    date_range = (now-time_span)..(now+time_span)

    overdue_projects = []
    overdue_done_projects = []
    done_projects = []
    intime_projects = []

    project_usedhours_rates = []

    projects = read_all_projects
    projects.each do |project|
      if now > project.due_date
        if project.delivered_at
          project_usedhours_rates.push(project.used_hours / project.total_hours) if project.total_hours > 0

          if date_range === project.due_date || date_range === project.delivered_at
            if project.delivered_at <= project.due_date
              done_projects.push(project)
            else
              overdue_done_projects.push(project)
            end
          end
        else
          if project.used_hours > project.total_hours
            project_usedhours_rates.push(project.used_hours / project.total_hours) if project.total_hours > 0
          end
          overdue_projects.push(project)
        end
      else
        if date_range === project.due_date
          if project.used_hours > project.total_hours
            project_usedhours_rates.push(project.used_hours / project.total_hours) if project.total_hours > 0
          end
          intime_projects.push(project)
        end
      end
    end

    customer_happyness_index = CompanyIndex.new
    customer_happyness_index.name = "Índice Deadline"
    customer_happyness_index.description = "Quanto mais POSITIVO melhor, negativo significa projetos atrasados"
    count = overdue_projects.length + overdue_done_projects.length + done_projects.length
    sum = (done_projects.length * 3) + (overdue_projects.length * -3) + (overdue_done_projects.length * -1)
    customer_happyness_index.value = (100.0 * sum) / (count > 0 ? (count * 3.0) : 1)
    # puts customer_happyness_index.to_json

    hours_use_index = CompanyIndex.new
    hours_use_index.name = "Índice Uso Horas"
    hours_use_index.description = "ABAIXO de 100 melhor, acima de 100 significa uso demasiado de horas para conclusão de projeto"
    hours_use_index.value = (100.0 * project_usedhours_rates.sum) / (project_usedhours_rates.length > 0 ? project_usedhours_rates.length : 1)
    # puts hours_rate_index.to_json

    [customer_happyness_index, hours_use_index]
  end

  def read_all_projects
    credentials = authorize_google_sheets
    projects = nil
    read_spreadsheet(credentials, "1wEXMX-D7BRo5YAQJXy2I6W6YyD4p9Jo53-jPOASYSHs", 'Projetos!A2:G') do |rows|
      projects = (rows || []).map { |row| ProjectSummary.from_row(row) }
    end
    projects
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

  def send_indexes(indexes)
    IndexesMailer.list(indexes).deliver
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
