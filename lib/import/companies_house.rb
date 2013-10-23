module Import

  class CompaniesHouse

    extend RowToRdf

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
        puts e.to_s
      end

      return codes


    end

    # it takes time to look up every company via Companies House linked data
    # do it once and store the results in a json file
    # as a hash, with company number as key, and array of SIC codes as values
    # input file is the spreadsheet containing company numbers
    def self.build_sic_code_hash(input_filename)
      code_hash = {}
      input_file = File.join(Rails.root, 'data', 'input-data', input_filename)
      excel = Roo::Excelx.new(input_file)
      # company number is in column 28
      for i in 2..excel.last_row
        puts i
        org_number = RowToRdf.clean_company_number(excel.cell(i,28))
        if org_number
          puts org_number
          if code_hash[org_number]
            # already done this one
            puts "Already got it"
          else
            codes = Import::CompaniesHouse.sicCodes(org_number)
            code_hash[org_number] = codes
          end
        end

      end

      # write result to file
      output_file = File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'company_to_sic_code.json')
      f = File.new(output_file,'w')
      f << code_hash.to_json
      f.close

    end

  end

end