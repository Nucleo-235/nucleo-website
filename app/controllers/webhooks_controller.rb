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
    original_date = Time.new

    # sempre segundas
    diff_days = original_date.wday > 0 ? (original_date.wday - 1) : 6
    base_date = Time.new(original_date.year, original_date.month, original_date.day).advance(days: -1 * diff_days)

    sales_indexes = calculate_sales_indexes(base_date)
    followups = get_followups(base_date)

    send_indexes(base_date, sales_indexes, nil, followups)
    render json: { message: "indexes sent" }, status: :ok
  end

  def projects
    original_date = Time.new

    # sempre segundas
    diff_days = original_date.wday > 0 ? (original_date.wday - 1) : 6
    base_date = Time.new(original_date.year, original_date.month, original_date.day).advance(days: -1 * diff_days)

    projects = get_projects(base_date)
    ProjectsMailer.all_projects(projects, base_date).deliver

    render json: { message: "projects sent" }, status: :ok
  end

  def calculate_sales_indexes(base_date)
    time_span = 3.month
    begin_date = base_date - time_span
    begin_date_str = begin_date.strftime("%Y-%m-%d")
    end_date = base_date
    end_date_str = end_date.strftime("%Y-%m-%d")

    airtable_results = SalesService.get_all_sales_results(begin_date_str, end_date_str)
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
    started_index.level = SalesService.sales_level(started_index)
    started_index.value_prefix = ""
    started_index.value_precision = 0
    started_index.save

    started_value_index = CompanyIndex.find_or_create_by(code: "order_started_value_3_months", reference_date: base_date)
    started_value_index.name = "$ Orçada"
    started_value_index.description = "Valor deve estar na faixa #{estimate_ideal_value} a cada 3 meses"
    started_value_index.value = SalesService.airtable_order_value(started).sum
    started_value_index.calculation_params = { range: started_ideal_values }
    started_value_index.level = SalesService.sales_level(started_value_index)
    started_value_index.value_prefix = "R$ "
    started_value_index.value_precision = 2
    started_value_index.save

    approved_index = CompanyIndex.find_or_create_by(code: "order_approved_count_3_months", reference_date: base_date)
    approved_index.name = "Qtd Aprovada"
    approved_index.description = "Valor deve estar na faixa #{order_ideal_count} a cada 3 meses"
    approved_index.value = approved.count
    approved_index.calculation_params = { range: approved_ideal_counts }
    approved_index.level = SalesService.sales_level(approved_index)
    approved_index.value_prefix = ""
    approved_index.value_precision = 0
    approved_index.save

    approved_value_index = CompanyIndex.find_or_create_by(code: "order_approved_value_3_months", reference_date: base_date)
    approved_value_index.name = "$ Aprovada"
    approved_value_index.description = "Valor deve estar na faixa #{order_ideal_value} a cada 3 meses"
    approved_value_index.value = SalesService.airtable_order_value(approved).sum
    approved_value_index.calculation_params = { range: approved_ideal_values }
    approved_value_index.level = SalesService.sales_level(approved_value_index)
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

  def calculate_execution_indexes(base_date, time_span)
    now = base_date
    date_range = (now-time_span)..(now+time_span)

    overdue_projects = []
    overdue_done_projects = []
    done_projects = []
    intime_projects = []

    project_usedhours_rates = []

    projects = ProjectsService.read_all_projects { |row| ProjectSummary.from_row(row) }
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

  def get_followups(base_date)
    time_span = 9.month
    time_span_end = 1.weeks
    begin_date = base_date - time_span
    begin_date_str = begin_date.strftime("%Y-%m-%d")
    end_date = base_date - time_span_end
    end_date_str = end_date.strftime("%Y-%m-%d")

    airtable_results = SalesService.get_all_followups(begin_date_str, end_date_str)
  end

  def get_projects(base_date)
    begin_date_str = (base_date - 1.week).strftime("%Y-%m-%d")
    end_date_str = base_date.strftime("%Y-%m-%d")
    major_begin_date_str = (base_date - 3.months).strftime("%Y-%m-%d")
    major_end_date_str = base_date.strftime("%Y-%m-%d")

    airtable_results = ProjectsService.get_all_projects(begin_date_str, end_date_str, major_begin_date_str, major_end_date_str)
  end

  def render_link_results(links, status = :ok)
    render json: { message: (links.count > 0 ? "mail sent" : "no mail sent") }, status: status
  end

  def send_sheets_links(spreadsheet_id, range, mail_method)
    GoogleSheetsService.read_spreadsheet(spreadsheet_id, range) do |rows|
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

  def send_indexes(base_date, sales_indexes, execution_indexes = nil, followups = nil)
    IndexesMailer.sales(sales_indexes, base_date).deliver
    IndexesMailer.execution(execution_indexes, base_date).deliver if execution_indexes
    if followups
      IndexesMailer.followups_required(followups[:required], base_date).deliver if followups[:required].length > 0
    end
  end

end
