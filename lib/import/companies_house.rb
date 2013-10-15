module Import
  
  class CompaniesHouse
    
    # takes the company number (as a string), looks up the Companies House linked data URI for that company
    # and returns an array of SIC codes (as strings). If the company URI is not found, returns an empty array
    def self.sicCodes(company_number)
      codes = []
      ch_uri = "http://data.companieshouse.gov.uk/doc/company/" + company_number + ".json"
      begin
        response = RestClient.get ch_uri  
        j = JSON.parse(response.body)
        # get an array of strings, where each string is something like
        # '62012 - Business and domestic software development'
        if j["primaryTopic"] && j["primaryTopic"]["SICCodes"]
          result = j["primaryTopic"]["SICCodes"]["SicText"] 
          # retrieve just the numerical part at the start of the string - always 5 digits
          result.each do |code|
            codes << code.split(' ').first
          end
        end
      rescue => e
        puts "#{ch_uri} #{e.response.code if e.response}"
      end      
      
      return codes
      
      
    end
    
  end
  
end