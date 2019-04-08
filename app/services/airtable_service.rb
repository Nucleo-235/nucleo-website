module AirtableService
  class << self
    def airtable_base_ids
      ['apph5wSohoj1CeRmC', 'apphxrTaZcPENxejr', 'appDUFqsL0ttGBYr9', 'appSPjyQ6qSGrYcyy']
    end

    def get_from_airtable(url)
      auth = "Bearer #{ENV['AIRTABLE_API']}"
      response = RestClient.get(url, {:Authorization => auth })
      JSON.parse(response)["records"]
    end
  end
end