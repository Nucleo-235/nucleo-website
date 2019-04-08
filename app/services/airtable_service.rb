module AirtableService
  class << self
    def get_from_airtable(url)
      auth = "Bearer #{ENV['AIRTABLE_API']}"
      response = RestClient.get(url, {:Authorization => auth })
      JSON.parse(response)["records"]
    end
  end
end