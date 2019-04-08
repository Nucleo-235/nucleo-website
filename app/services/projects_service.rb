module ProjectsService
  class << self

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