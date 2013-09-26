module Import
  module RowToRdf
    
    REGIONS = {
      "East Midlands" => "http://data.statistics.gov.uk/id/statistical-geography/E12000004", 
      "West Midlands" => "http://data.statistics.gov.uk/id/statistical-geography/E12000005",
      "South West" => "http://data.statistics.gov.uk/id/statistical-geography/E12000009",
      "South East" => "http://data.statistics.gov.uk/id/statistical-geography/E12000008",
      "North West" => "http://data.statistics.gov.uk/id/statistical-geography/E12000002",
      "North East" => "http://data.statistics.gov.uk/id/statistical-geography/E12000001",
      "East of England" => "http://data.statistics.gov.uk/id/statistical-geography/E12000006",
      "Yorkshire and The Humber" => "http://data.statistics.gov.uk/id/statistical-geography/E12000003",
      "London" => "http://data.statistics.gov.uk/id/statistical-geography/E12000007"
    }
    
    def row2rdf(resources,row)

      ##### Project #####
      # uri: use TSBProjectNumber
      proj_num = row["TSBProjectNumber"].to_i.to_s
      project_uri = Vocabulary::TSB["project/#{proj_num}"]
      # if this project already exists, then don't do it again
      if resources[uri]
        p = resources[uri]
      else
        p = Project.new(project_uri)
        # add to resources hash
        resources[project_uri] = p
        project_title = row["ProjectTitle"]
        p.label = project_title
        description = row["PublicDescription"]
        # clean up description - replace double line breaks with space chars.
        description.gsub!(/\n\n/,' ')
        p.description = description
        p.project_number = proj_num
        
        ## TO DO - sort out date formatting
        t1 = row["StartDate"]
        t2 = row["ProjectEndDate"]
  #      p.start_date = RDF::Literal::Date.new(t1)
  #      p.end_date = RDF::Literal::Date.new(t2)
        
      end
      
      
 


      ##### Organization ####
      # uri: use company number if it exists.
      # if no company number, then use urlified name
      org_name = row["ParticipantName"]
      urlified_org_name = urlify(org_name)
      org_number = row["CompanyRegNo"]
      org_slug = nil
      if org_number
        org_slug = org_number.to_s

        # normalise the format - add leading zeroes if necessary
        unless org_slug.starts_with?('RC')
          while org_slug.length < 8
            org_slug = "0" + org_slug
          end
          
        end
      else
        org_slug = urlified_org_name
      end
      puts org_slug

      org_uri = Vocabulary::TSB["organization/#{org_slug}"]
      
      # if org exists, don't do it again
      if resources[uri]
        o = resources[uri]
      else
        o = Organization.new(uri)
        # add to resources hash
        resources[uri] = o
        o.label = org.name
        o.company_number = org_number
        # for now, ignore the case where an org might have two addresses - just use the first one
        site_uri = Vocabulary::TSB["organization/#{org_slug}/site"]
        address_uri = Vocabulary::TSB["organization/#{org_slug}/address"]
        # will only do site and address once for each org
        s = Site.new(site_uri)
        o.site = s
        a = Address.new(address_uri)
        s.label = "Site of #{org_name}"
        s.address = a

        # clean up the address cell of the spreadsheet, removing line breaks
        address = row["Address"]
        cleaned_address = address.gsub(/\n/,', ')
        a.street_address = cleaned_address
        a.locality = row["Town"]
        a.county = row["County"]
        a.postcode = row["Postcode"]
        
        region = row["ValidatedRegion"].strip
        region_uri = REGIONS[region]
        r = Region.new(region_uri)
        s.region = r



        # postcode - connect to OS URI - what should the subject be? the organization? the site?
        postcode = row["Postcode"].gsub(/ /,'') # remove spaces
        pc_uri = Vocabulary::OSPC[pc]
        pc = Postcode.new(pc_uri)
        
        s.postcode = pc
        
        # TODO Look up location and district for OS postcode and connect to site.
        
        # TODO connect company to OpenCorporates and Companies House
        
      end


      #TODO translate the remaining RDF.rb stuff into Tripod

      # Grant
      grant_uri = Vocabulary::TSB["grant/#{proj_num}/#{org_slug}"]

      graph << [grant_uri, RDF.type, Vocabulary::TSBDEF.Grant]
      graph << [grant_uri, RDF::RDFS.label, RDF::Literal.new("Grant for #{org_name}, project: #{project_title}")]

      graph << [grant_uri, Vocabulary::TSBDEF.offerCost, RDF::Literal.new(row["OfferCost"].to_i)]
      graph << [grant_uri, Vocabulary::TSBDEF.offerGrant, RDF::Literal.new(row["OfferCost"].to_i)]
      graph << [grant_uri, Vocabulary::TSBDEF.offerPercentage, RDF::Literal.new(row["OfferRateOfGrant"])]
      graph << [grant_uri, Vocabulary::TSBDEF.paymentsToDate, RDF::Literal.new(row["PaymentsToDate"].to_i)]


      ##### connections #####

      # org - project (2 way)
      graph << [org_uri, Vocabulary::TSBDEF.participatesIn, project_uri]
      graph << [project_uri, Vocabulary::TSBDEF.hasParticipant,org_uri]
      if row["IsLead"] && row["IsLead"] == "Lead"
        graph << [org_uri, Vocabulary::TSBDEF.isLeaderOf, project_uri]
        graph << [project_uri, Vocabulary::TSBDEF.hasLeader, org_uri]
      end

      # grant - org
      graph << [grant_uri, Vocabulary::TSBDEF.paidTo, org_uri]

      # grant - project
      graph << [grant_uri, Vocabulary::TSBDEF.supports, project_uri]
      graph << [project_uri, Vocabulary::TSBDEF.supportedBy, grant_uri]



      return nil
    end
  end
end