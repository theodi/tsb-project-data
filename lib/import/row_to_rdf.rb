module Import
  module RowToRdf
    def row2rdf(graph,row)

      ##### Project #####
      # uri: use TSBProjectNumber
      proj_num = row["TSBProjectNumber"].to_i.to_s
      project_uri = Vocabulary::TSB["project/#{proj_num}"]
      project_title = row["ProjectTitle"]

      #type, label, description
      graph << [project_uri, RDF.type, Vocabulary::TSBDEF.Project]
      graph << [project_uri, RDF::RDFS.label, RDF::Literal.new(project_title)]

      description = row["PublicDescription"]

      # clean up description - replace double line breaks with space chars.
      description.gsub!(/\n\n/,' ')
      graph << [project_uri, Vocabulary::DCTERMS.description, RDF::Literal.new(description)]


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

      graph << [org_uri, RDF.type, Vocabulary::TSBDEF.Organization]
      graph << [org_uri, RDF::RDFS.label, RDF::Literal.new(org_name)]

      # address
      # TODO: check whether any org appears in the spreadsheet with more than one different address.
      site_uri = Vocabulary::TSB["organization/#{org_slug}/site"]
      address_uri = Vocabulary::TSB["organization/#{org_slug}/address"]
      graph << [org_uri, Vocabulary::ORG.hasSite, site_uri]
      graph << [site_uri, RDF.type, Vocabulary::ORG.Site]
      graph << [site_uri, RDF::RDFS.label, RDF::Literal.new("Site of #{org_name}")]
      graph << [site_uri, Vocabulary::ORG.siteAddress, address_uri]
      graph << [address_uri, RDF.type, Vocabulary::VCARD.Address]
      graph << [address_uri, RDF::RDFS.label, RDF::Literal.new("Site address of #{org_name}")]
      # clean up the address cell of the spreadsheet, removing line breaks
      address = row["Address"]
      cleaned_address = address.gsub(/\n/,', ')
      graph << [address_uri, Vocabulary::VCARD["street-address"],RDF::Literal.new(cleaned_address)]
      graph << [address_uri, Vocabulary::VCARD.locality, RDF::Literal.new(row["Town"])]
      graph << [address_uri, Vocabulary::VCARD.region,RDF::Literal.new(row["County"])]
      graph << [address_uri, Vocabulary::VCARD["postal-code"],RDF::Literal.new(row["Postcode"])]


      # postcode - connect to OS URI - what should the subject be? the organization? the site?
      pc = row["Postcode"].gsub(/ /,'') # remove spaces
      pc_uri = Vocabulary::OSPC[pc]
      graph << [site_uri, Vocabulary::OSDEF.postcode, pc_uri]

      # company number - connect to OpenCorporates and Companies House


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


      return graph
    end
  end
end