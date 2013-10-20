module Import
  module RowToRdf

    require 'cgi'

    REGIONS = {
      "East Midlands" => "http://statistics.data.gov.uk/id/statistical-geography/E12000004",
      "West Midlands" => "http://statistics.data.gov.uk/id/statistical-geography/E12000005",
      "South West" => "http://statistics.data.gov.uk/id/statistical-geography/E12000009",
      "South East" => "http://statistics.data.gov.uk/id/statistical-geography/E12000008",
      "North West" => "http://statistics.data.gov.uk/id/statistical-geography/E12000002",
      "North East" => "http://statistics.data.gov.uk/id/statistical-geography/E12000001",
      "East of England" => "http://statistics.data.gov.uk/id/statistical-geography/E12000006",
      "Yorkshire and The Humber" => "http://statistics.data.gov.uk/id/statistical-geography/E12000003",
      "London" => "http://statistics.data.gov.uk/id/statistical-geography/E12000007",
      "Northern Ireland" => "http://statistics.data.gov.uk/id/statistical-geography/N92000002",
      "Scotland" => "http://statistics.data.gov.uk/id/statistical-geography/S92000003",
      "Wales" => "http://statistics.data.gov.uk/id/statistical-geography/W92000004"
    }

    def row2rdf(resources,row,org_sic_hash)

      modified_datetime = DateTime.now

      ##### Project #####
      # uri: use TSBProjectNumber
      proj_num = row["TSBProjectNumber"].to_i.to_s
      project_uri = Vocabulary::TSB["project/#{proj_num}"]
      project_title = row["ProjectTitle"]
      # if this project already exists, then don't do it again
      if resources[project_uri]
        p = resources[project_uri]
      else
        p = Project.new(project_uri)
        # add to resources hash
        resources[project_uri] = p
        p.label = project_title
        description = row["Project Description"].to_s
        # clean up description - replace double line breaks with space chars.
        description = "No description available" unless description && description.length > 0
        description.gsub!(/\n\n/,' ')
        p.description = description
        p.project_number = proj_num
        status = row["ProjectStatus"]
        if status && status.length > 0
          status_uri = Vocabulary::TSBDEF["concept/project-status/#{Urlify::urlify(status)}"]
          p.project_status_uri = status_uri
        end
        duration_uri = Vocabulary::TSB["project/#{proj_num}/duration"]
        d = ProjectDuration.new(duration_uri)
        p.duration = d
        resources[duration_uri] = d

        ## TO DO - sort out date formatting
        min_valid_date = Date.parse('2000-01-01')
        dummy_date = Date.parse('2001-04-01')
        t1 = row["StartDate"]
        t2 = row["ProjectEndDate"]
        if t1 < min_valid_date || t2 < min_valid_date
          t1 = dummy_date
          t2 = dummy_date
        end
        d.start  = t1.strftime('%Y-%m-%d')
        d.end = t2.strftime('%Y-%m-%d')
        d.label = "From #{t1.strftime('%d/%m/%Y')} to #{t2.strftime('%d/%m/%Y')}"
        costcat = row["CostCategoryType"]
        if ["Industrial","Academic"].include?(costcat)
          cc_uri = Vocabulary::TSBDEF["concept/cost-category/#{Urlify::urlify(costcat)}"]
          cc = CostCategory.new(cc_uri)
          p.cost_category = cc
        end

      end





      ##### Organization ####
      # uri: use company number if it exists.
      # if no company number, then use urlified name
      org_name = row["ParticipantName"]
      urlified_org_name = Urlify::urlify(org_name)
      org_slug = nil
      org_number = RowToRdf.clean_company_number(row["CompanyRegNo"])

      if org_number
        org_slug = org_number
      else  # org_number is nil: no company num at all
        org_slug = urlified_org_name
      end

      org_uri = Vocabulary::TSB["organization/#{org_slug}"]

      # if org exists, don't do it again
      if resources[org_uri]
        o = resources[org_uri]
      else
        o = Organization.new(org_uri)
        # add to resources hash
        resources[org_uri] = o
        o.label = org_name
        o.company_number = org_number if org_number

        # for now, ignore the case where an org might have two addresses - just use the first one
        site_uri = Vocabulary::TSB["organization/#{org_slug}/site"]
        address_uri = Vocabulary::TSB["organization/#{org_slug}/address"]

        # will only do site and address once for each org
        s = Site.new(site_uri)
        o.site = s
        a = Address.new(address_uri)
        s.label = "Site of #{org_name}"
        s.address = a

        resources[site_uri] = s
        resources[address_uri] = a

        # clean up the address cell of the spreadsheet, removing line breaks
        address = row["Address"]
        if address && address.length > 0 && address != "null"
          cleaned_address = address.gsub(/\n/,', ')
          a.street_address = cleaned_address
        end
        a.locality = row["Town"] if row["Town"] && row["Town"] != "null"
        a.county = row["County"] if row["County"] && row["County"] != "null"
        a.postcode = row["Postcode"] if row["Postcode"] && row["Postcode"] != "null"

        region = row["Validated Region"].strip
        region_uri = REGIONS[region]
        if region_uri
          r = Region.new(region_uri)
          s.region = r
        else
          puts "nil region #{region}"
        end



        # postcode - connect to OS URI - what should the subject be? the organization? the site?
        if row["Postcode"] && row["Postcode"] != "null"
          postcode = row["Postcode"].gsub(/ /,'') # remove spaces
          pc_uri = Vocabulary::OSPC[postcode]

          s.postcode = pc_uri

          # Look up location and district for OS postcode and connect to site.
          query = "SELECT ?lat ?long ?district_gss WHERE {
            <#{pc_uri}> <http://www.w3.org/2003/01/geo/wgs84_pos#lat> ?lat .
            <#{pc_uri}> <http://www.w3.org/2003/01/geo/wgs84_pos#long> ?long .
            <#{pc_uri}> <http://data.ordnancesurvey.co.uk/ontology/postcode/district> ?os_district .
            ?os_district <http://www.w3.org/2002/07/owl#sameAs> ?district_gss
          }"

          encoded_query = CGI::escape(query)
          query_url = "http://opendatacommunities.org/sparql.json?query=" + encoded_query + "&api_key=346ead3fc7282de4827f2a5cf408b089"
          response = JSON.parse(RestClient.get query_url)
          result = response["results"]["bindings"][0]
          if result
            lat = result["lat"]["value"] if result["lat"]
            long = result["long"]["value"] if result["long"]
            district = result["district_gss"]["value"] if result["district_gss"]
            s.lat = lat if lat
            s.long = long if long
            s.district = district if district
          else
            # postcode not found - try looking it up from ONSPD - could be Northern Irish
          
          end
        end

        # legal entity form and enterprise size
        esize = row["EnterpriseSize"]
        if esize && esize != "null"
          esize_uri = Vocabulary::TSBDEF["concept/enterprise-size/#{Urlify::urlify(esize)}"]
          o.enterprise_size = EnterpriseSize.new(esize_uri)
        end
        legal_form_code = LegalEntityForm::LEGAL_ENTITY_FORMS[row["ParticipantOrganisationType"]]
        if legal_form_code && legal_form_code != "null"
          form = LegalEntityForm.new(Vocabulary::TSBDEF["concept/legal-entity-form/#{legal_form_code}"])
          o.legal_entity_form = form
        end




        # retrieve SIC codes from Companies House
        if org_number
          # TODO - enhance this so that if there is no sic code for an org, look it up at Companies House
          # and if anything found, save it back to the cache
                  
          codes = org_sic_hash[org_number]
          if codes && codes.length > 0
            codes.each do |code|
              sic_uri = Vocabulary::TSBDEF["concept/sic/#{code}"]
              o.sic_classes_uris = o.sic_classes_uris.push(sic_uri)
            end
          end
          # codes = Import::CompaniesHouse.sicCodes(org_number)
          # codes.each do |code|
          #   sic_uri = Vocabulary::TSBDEF["concept/sic/#{code}"]
          #   o.sic_class_uris = o.sic_class_uris.push(sic_uri)
          # end

          # connect company to OpenCorporates and Companies House
          # TODO - should check whether the remote URIs exist
          opencorp_uri = "http://opencorporates.com/id/companies/gb/#{org_number}"
          ch_uri = "http://business.data.gov.uk/id/company/#{org_number}"
          o.same_as = [opencorp_uri,ch_uri]


        end


      end # of organization block

      ##### Competition #####
      comp_year = row["CompetitionYear"].to_i.to_s
      comp_call_code = row["CompCallCode"].to_s
      activity_code = row["ActivityCode"].to_i.to_s
      # fill out the activity code with leading zeroes, if it is shorter than 4 chars
      while activity_code.length < 4
        activity_code = "0" + activity_code
      end

      product = row["Product"].strip
      area = row["AreaBudgetHolder"].strip
  #    team = row["TeamBudgetHolder"].strip
      subarea = row["AreaName"]

      # use Activity Code as the unique identifier for a Competition

      comp_uri = Vocabulary::TSB["competition/#{activity_code}"]
      # have we done this competition?
      if resources[comp_uri]
        comp = resources[comp_uri]
      else
        comp = Competition.new(comp_uri)
        resources[comp_uri] = comp

        comp.competition_code = comp_call_code
        comp.competition_year = Vocabulary::REF["year/#{comp_year}"]
        comp.activity_code = activity_code
        comp.label = "Competition #{activity_code}"


        # check we are not missing any codes
        puts "unknown product value #{product}" unless Product::PRODUCT_CODES[product]
  #      puts team unless Team::TEAM_CODES[team]
        puts "unknown area value #{area}" unless BudgetArea::BUDGET_AREA_CODES[area]

        # Don't use team
        # team_code = Team::TEAM_CODES[team]
        #    if team_code && team_code != "null"
        #      t_uri = Vocabulary::TSB["team/#{team_code}"]
        #      comp.team_uri = t_uri
        #         end
        budget_area_code = BudgetArea::BUDGET_AREA_CODES[area]
        if budget_area_code && budget_area_code != "null"
          budg_uri = Vocabulary::TSB["budget-area/#{budget_area_code}"]
          comp.budget_area_uri = budg_uri
        end
        # NB use '_uri' setter methods as linking to a URI, not a Tripod Resource
        product_code = Product::PRODUCT_CODES[product]
        if product_code && product_code != "null"
          prod_uri = Vocabulary::TSBDEF["concept/product/#{product_code}"]
          comp.product_uri = prod_uri
        end


      end

      #link project to competition (if not already done)
      p.competition = comp unless p.competition_uri



      # Grant
      grant_uri = Vocabulary::TSB["grant/#{proj_num}/#{org_slug}"]

      # is there already a grant for this combination of organisation and project?
      # if so, assign a separate URI for this one by adding /1 or /2 etc at the end.

      exists = resources[grant_uri]
      i = 1

      while exists
        grant_uri = Vocabulary::TSB["grant/#{proj_num}/#{org_slug}/#{i.to_s}"]
        exists = resources[grant_uri]
        i += 1
      end


      g = Grant.new(grant_uri)
      resources[grant_uri] = g

      if i ==1
        g.label = "Grant for #{org_name}, project: #{project_title}"
      else
        g.label = "Grant number #{i.to_s} for #{org_name}, project: #{project_title}"
      end
      g.offer_cost = row["OfferCost"].to_i
      g.offer_grant = row["OfferGrant"].to_i
      g.offer_percentage = row["OfferRateOfGrant"]
      g.payments_to_date = row["PaymentsToDate"]


      ##### connections #####

      # grant - project

      g.supports_project = p
      p.supported_by_uris = p.supported_by_uris.push(g.uri)

      # org - project (2 way)
      o.participates_in_projects_uris = o.participates_in_projects_uris.push(p.uri)
      p.participants_uris = p.participants_uris.push(o.uri)

      if row["IsLead"] && row["IsLead"] == "Lead"
        o.leads_projects_uris = o.leads_projects_uris.push(p.uri)
        p.leader = o
      end

      # grant - org
      g.paid_to_organization = o

      p.modified = modified_datetime
      g.modified = modified_datetime

      return nil
    end

    # takes the cell from the spreadsheet and tidies it up into a company number
    # if it can't make a company number out of it, returns nil
    def self.clean_company_number(raw_number)
      org_number = nil
      if raw_number
        # does the spreadsheet/Roo think it's a number or a string?
        if raw_number.class == Float
          org_number = raw_number.to_i.to_s
        else
          org_number = raw_number.strip
        end

        if ["0","","Exempt Charity","NHS Hospital", "N/A", "null"].include?(org_number)
          org_number = nil
        else
          # normalise the format
          # replace any spaces with '-'
          org_number.gsub!(/ /,'-')
          #  add leading zeroes if necessary
          unless org_number.starts_with?('RC')
            while org_number.length < 8
              org_number = "0" + org_number
            end

          end
        end


      end

      return org_number

    end

  end
end