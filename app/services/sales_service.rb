module SalesService
  class << self
    def join_airtable_results(results_lists)
      final_result = { started: [], approved: [] }
      results_lists.each do |results|
        final_result[:started] = final_result[:started] + results[:started]
        final_result[:approved] = final_result[:approved] + results[:approved]
      end
      final_result
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
        if  fields["Valor Aprovado"] && fields["Valor Aprovado"] > 0 
          fields["Valor Aprovado"]
        else
          fields["Valor Final"] && fields["Valor Final"] > 0 ? fields["Valor Final"] : 0
        end
      end
      # puts final_results.to_json
      final_results
    end

    def get_airtable_results(base_url, begin_date_str, end_date_str)
      data_field = 'Data'
      filter = "AND(NOT(Status = ''), NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}&filterByFormula=#{filter_string}"
      started = AirtableService.get_from_airtable(url)
  
      data_field = 'Data Aprovação'
      filter = "AND(OR(Status = 'Aprovado', Status = 'Em Produção', Status = 'Entregue'), NOT({#{data_field}} = ''), IS_AFTER({#{data_field}},DATETIME_PARSE('#{begin_date_str}', 'YYYY-MM-DD')), IS_BEFORE({#{data_field}},DATETIME_PARSE('#{end_date_str}', 'YYYY-MM-DD')))"
      filter_string = ERB::Util.u(filter)
      url = "#{base_url}&filterByFormula=#{filter_string}"
      approved = AirtableService.get_from_airtable(url)
  
      { started: started, approved: approved }
    end
  end
end