module SalesService
  class << self
    def get_all_sales_results(begin_date_str, end_date_str)
      airtable_base_results = AirtableService.airtable_base_ids.map do |base_id|  
        SalesService.get_sales_results("https://api.airtable.com/v0/" + base_id[:key] + "/Projetos", base_id, begin_date_str, end_date_str)
      end
      final_result = { started: [], approved: [] }
      airtable_base_results.each do |results|
        final_result[:started] = final_result[:started] + results[:started]
        final_result[:approved] = final_result[:approved] + results[:approved]
      end
      final_result
    end

    def get_sales_results(base_url, base_id, begin_date_str, end_date_str)
      data_field = 'Data'
      filter = "AND(NOT(Status = ''), NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      started = AirtableService.get_from_airtable(url, base_id)
  
      data_field = 'Data Aprovação'
      filter = "AND(OR(Status = 'Aprovado', Status = 'Em Produção', Status = 'Entregue'), NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}?filterByFormula=#{filter_string}"
      approved = AirtableService.get_from_airtable(url, base_id)
  
      { started: started, approved: approved }
    end

    def get_all_followups(begin_date_str, end_date_str)
      airtable_base_results = AirtableService.airtable_base_ids.map do |base_id|  
        SalesService.get_followups("https://api.airtable.com/v0/" + base_id[:key] + "/Projetos", base_id, begin_date_str, end_date_str)
      end
      final_result = { required: [] }
      airtable_base_results.each do |results|
        final_result[:required] = final_result[:required] + results[:required]
      end
      final_result
    end

    def get_followups(base_url, base_id, begin_date_str, end_date_str)
      data_field = 'Data Contato'
      filter = "AND(Status = 'Enviado', NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
      filter_string = ERB::Util.u(filter)
      sort_string = "#{ERB::Util.u("sort[0][field]")}=#{ERB::Util.u("Data Contato")}&#{ERB::Util.u("sort[0][direction]")}=#{ERB::Util.u("desc")}"
      url = "#{base_url}?filterByFormula=#{filter_string}&#{sort_string}"
      required = AirtableService.get_from_airtable(url, base_id)
      SalesService.set_final_values(required)
  
      { required: required }
    end

    def sales_level(index)
      range = index.calculation_params[:range].sort { |a, z| z <=> a }
      range_step = 100 / range.count
      range.each_with_index do |value, i|
        return 100 - (range_step * i) if index.value >= value
      end
      return 0
    end

    def set_final_values(results)
      results.each do |result| 
        fields = result["fields"]
        if  fields["Valor Aprovado"] && fields["Valor Aprovado"] > 0 
          fields[:final_value] = fields["Valor Aprovado"]
        else
          fields[:final_value] = fields["Valor Final"] && fields["Valor Final"] > 0 ? fields["Valor Final"] : 0
        end
      end
      results
    end

    def airtable_order_value(results)
      final_results = results.map do |result| 
        fields = result["fields"]
        if  fields["Valor Aprovado"] && fields["Valor Aprovado"] > 0 
          fields["Valor Aprovado"]
        else
          fields["Valor Final"] && fields["Valor Final"] > 0 ? fields["Valor Final"] : 0
        end
      end
      # puts final_results.to_json
      final_results
    end
  end
end