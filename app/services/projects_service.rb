module ProjectsService
  class << self

    def get_all_projects(begin_date_str, end_date_str, major_begin_date_str, major_end_date_str)
      airtable_base_results = AirtableService.airtable_base_ids.map do |base_id|  
        ProjectsService.get_projects("https://api.airtable.com/v0/" + base_id[:key] + "/Projetos", base_id, begin_date_str, end_date_str, major_begin_date_str, major_end_date_str)
      end
      final_result = { started: [], started_last_period: [], inprogress: [], delivered_last_period: [], delivered: [] }
      airtable_base_results.each do |results|
        final_result[:started] = final_result[:started] + results[:started] if results[:started]
        final_result[:started_last_period] = final_result[:started_last_period] + results[:started_last_period] if results[:started_last_period]
        final_result[:inprogress] = final_result[:inprogress] + results[:inprogress]  if results[:inprogress]
        final_result[:delivered_last_period] = final_result[:delivered_last_period] + results[:delivered_last_period] if results[:delivered_last_period]
        final_result[:delivered] = final_result[:delivered] + results[:delivered] if results[:delivered]
      end
      final_result
    end

    def get_projects(base_url, base_id, begin_date_str, end_date_str, major_begin_date_str, major_end_date_str)
      data_field = 'Data Status'
      filter = "AND(Status = 'Entregue', AND(NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD'))))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      delivered_last_period = AirtableService.get_from_airtable(url, base_id)
      SalesService.set_final_values(delivered_last_period)

      data_field = 'Data Status'
      filter = "AND(Status = 'Entregue', AND(NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{major_begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{major_end_date_str}', 'YYYY-MM-DD'))))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      delivered = AirtableService.get_from_airtable(url, base_id)
      SalesService.set_final_values(delivered)

      data_field = 'Data Status'
      filter = "AND(Status = 'Em Produção')"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      inprogress = AirtableService.get_from_airtable(url, base_id)
      SalesService.set_final_values(inprogress)

      data_field = 'Data Aprovação'
      filter = "AND(Status = 'Aprovado', AND(NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD'))))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      started_last_period = AirtableService.get_from_airtable(url, base_id)
      SalesService.set_final_values(started_last_period)

      data_field = 'Data Aprovação'
      filter = "AND(Status = 'Aprovado')"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      started = AirtableService.get_from_airtable(url, base_id)
      SalesService.set_final_values(started)
  
      { started: started, started_last_period: started_last_period, inprogress: inprogress, delivered_last_period: delivered_last_period, delivered: delivered }
    end

    def read_all_projects
      credentials = authorize_google_sheets
      projects = nil
      GoogleSheetsServie.read_spreadsheet("1wEXMX-D7BRo5YAQJXy2I6W6YyD4p9Jo53-jPOASYSHs", 'Projetos!A2:G') do |rows|
        projects = (rows || []).map { |row| yield row }
      end
      projects
    end
  end
end