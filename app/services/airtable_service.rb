module AirtableService
  class << self
    def airtable_base_ids
      [
        { key: 'apph5wSohoj1CeRmC', view_url: 'https://airtable.com/tblaIEbQRnJ6fIZnf' },
        { key: 'apphxrTaZcPENxejr', view_url: 'https://airtable.com/tblaazcCzbfJq1mk4' },
        { key: 'appDUFqsL0ttGBYr9', view_url: 'https://airtable.com/tblwxNJUlZTyj56sM' },
        { key: 'appSPjyQ6qSGrYcyy', view_url: 'https://airtable.com/tblLsrRiGpiL4skzb' }
      ]
    end

    def get_from_airtable(url, base_id)
      auth = "Bearer #{ENV['AIRTABLE_API']}"
      response = RestClient.get(url, {:Authorization => auth })
      records = JSON.parse(response)["records"]
      records.each do |result| 
        result["fields"][:view_url] = base_id[:view_url]
      end
      records
    end
  end
end