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
      original_date = Time.new

      # sempre segundas
      diff_days = original_date.wday > 0 ? (original_date.wday - 1) : 6
      base_date = Time.new(original_date.year, original_date.month, original_date.day).advance(days: -1 * diff_days)

      sales_indexes = calculate_sales_indexes(base_date, 3.month)
      execution_indexes = calculate_execution_indexes(base_date, 2.month)

      send_indexes(base_date, sales_indexes, execution_indexes)
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

    airtable_base_ids = ['apphxrTaZcPENxejr', 'appDUFqsL0ttGBYr9', 'appSPjyQ6qSGrYcyy']
    airtable_base_results = airtable_base_ids.map do |base_id|  
      get_airtable_results("https://api.airtable.com/v0/" + base_id + "/Projetos?view=Grid%20view", begin_date_str, end_date_str)
    end
    airtable_results = join_airtable_results(airtable_base_results)
    started = airtable_results[:started] || []
    approved = airtable_results[:approved] || []

    estimate_ideal_count = ENV["ESTIMATE_IDEAL_COUNT"]
    estimate_ideal_value = ENV["ESTIMATE_IDEAL_VALUE"]
    order_ideal_count = ENV["ORDER_IDEAL_COUNT"]
    order_ideal_value = ENV["ORDER_IDEAL_VALUE"]
    started_ideal_counts = estimate_ideal_count.split(",").map { |e| e.to_f }
    started_ideal_values = estimate_ideal_value.split(",").map { |e| e.to_f }
    approved_ideal_counts = order_ideal_count.split(",").map { |e| e.to_f }
    approved_ideal_values = order_ideal_value.split(",").map { |e| e.to_f }

    started_index = CompanyIndex.find_or_create_by(code: "order_started_count_3_months", reference_date: base_date)
    started_index.name = "Qtd Orçada"
    started_index.description = "Valor deve estar na faixa #{estimate_ideal_count} a cada 3 meses"
    started_index.value = started.count
    started_index.calculation_params = { range: started_ideal_counts }
    started_index.level = sales_level(started_index)
    started_index.value_prefix = ""
    started_index.value_precision = 0
    started_index.save

    started_value_index = CompanyIndex.find_or_create_by(code: "order_started_value_3_months", reference_date: base_date)
    started_value_index.name = "$ Orçada"
    started_value_index.description = "Valor deve estar na faixa #{estimate_ideal_value} a cada 3 meses"
    started_value_index.value = airtable_order_value(started).sum
    started_value_index.calculation_params = { range: started_ideal_values }
    started_value_index.level = sales_level(started_value_index)
    started_value_index.value_prefix = "R$ "
    started_value_index.value_precision = 2
    started_value_index.save

    approved_index = CompanyIndex.find_or_create_by(code: "order_approved_count_3_months", reference_date: base_date)
    approved_index.name = "Qtd Aprovada"
    approved_index.description = "Valor deve estar na faixa #{order_ideal_count} a cada 3 meses"
    approved_index.value = approved.count
    approved_index.calculation_params = { range: approved_ideal_counts }
    approved_index.level = sales_level(approved_index)
    approved_index.value_prefix = ""
    approved_index.value_precision = 0
    approved_index.save

    approved_value_index = CompanyIndex.find_or_create_by(code: "order_approved_value_3_months", reference_date: base_date)
    approved_value_index.name = "$ Aprovada"
    approved_value_index.description = "Valor deve estar na faixa #{order_ideal_value} a cada 3 meses"
    approved_value_index.value = airtable_order_value(approved).sum
    approved_value_index.calculation_params = { range: approved_ideal_values }
    approved_value_index.level = sales_level(approved_value_index)
    approved_value_index.value_prefix = "R$ "
    approved_value_index.value_precision = 2
    approved_value_index.save

    detailed_indexes = [started_index, started_value_index, approved_index, approved_value_index]

    overall_index = CompanyIndex.find_or_create_by(code: "overall_3_months", reference_date: base_date)
    overall_index.name = "Geral"
    overall_index.description = "Índice geral baseado nos índices detalhados"
    overall_index.value = detailed_indexes.inject(0){|sum,e| sum + e.level }
    overall_index.calculation_params = {  }
    overall_index.level = overall_index.value / detailed_indexes.length
    overall_index.value_prefix = ""
    overall_index.value_precision = 0
    overall_index.save

    { overall: overall_index, detailed: detailed_indexes }
  end

  def sales_level(index)
    range = index.calculation_params[:range].sort { |a, z| z <=> a }
    range_step = 100 / range.count
    range.each_with_index do |value, i|
      return 100 - (range_step * i) if index.value >= value
    end
    return 0
  end

  def airtable_order_value(results)
    final_results = results.map do |result| 
      fields = result["fields"]
      fields["Valor Aprovado"] && fields["Valor Aprovado"] > 0 ? fields["Valor Aprovado"] : fields["Valor Final"]
    end
    # puts final_results.to_json
    final_results
  end

  def join_airtable_results(results_lists)
    final_result = { started: [], approved: [] }
    results_lists.each do |results|
      final_result[:started] = final_result[:started] + results[:started]
      final_result[:approved] = final_result[:approved] + results[:approved]
    end
    final_result
  end

  def get_airtable_results(base_url, begin_date_str, end_date_str)
    auth = "Bearer #{ENV['AIRTABLE_API']}"

    data_field = 'Data'
    filter = "AND(NOT(Status = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
    filter_string = ERB::Util.u(filter)
    url = "#{base_url}&filterByFormula=#{filter_string}"
    started = get_from_airtable(url)

    data_field = 'Data Aprovação'
    filter = "AND(Status = 'Aprovado', IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
    filter_string = ERB::Util.u(filter)
    url = "#{base_url}&filterByFormula=#{filter_string}"
    approved = get_from_airtable(url)

    { started: started, approved: approved }
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

    customer_happyness_index = CompanyIndex.find_or_create_by(code: "customer_happyness", reference_date: base_date)
    customer_happyness_index.name = "Índice Deadline"
    customer_happyness_index.description = "Quanto mais POSITIVO melhor, negativo significa projetos atrasados"
    count = overdue_projects.length + overdue_done_projects.length + done_projects.length
    sum = (done_projects.length * 3) + (overdue_projects.length * -3) + (overdue_done_projects.length * -1)
    customer_happyness_index.value = (100.0 * sum) / (count > 0 ? (count * 3.0) : 1)
    customer_happyness_index.calculation_params = { done_weigth: 3, overdue_weigth: -3, overdue_done_weigth: -1 }
    customer_happyness_index.save
    # puts customer_happyness_index.to_json

    hours_use_index = CompanyIndex.find_or_create_by(code: "hours_use", reference_date: base_date)
    hours_use_index.name = "Índice Uso Horas"
    hours_use_index.description = "ABAIXO de 100 melhor, acima de 100 significa uso demasiado de horas para conclusão de projeto"
    hours_use_index.value = (100.0 * project_usedhours_rates.sum) / (project_usedhours_rates.length > 0 ? project_usedhours_rates.length : 1)
    hours_use_index.save
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

  def send_indexes(base_date, sales_indexes, execution_indexes)
    IndexesMailer.sales(sales_indexes, base_date).deliver
    IndexesMailer.execution(execution_indexes, base_date).deliver
  end

  def read_spreadsheet(credentials, spreadsheet_id, range)
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
