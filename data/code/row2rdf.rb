require 'rdf'
require './urlify.rb'

# temporary domain for URIs:
domain = "http://tsb.swirrl.com"

# useful vocabs
RDFS = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")

POST  = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/id/postcodeunit/")
STATS   = RDF::Vocabulary.new("http://statistics.data.gov.uk/id/statistical-geography/")
YEAR  = RDF::Vocabulary.new("http://reference.data.gov.uk/id/year/")
TSBDEF = RDF::Vocabulary.new(domain + "/def/")
TSB = RDF::Vocabulary.new(domain + "/id/")
ORG = RDF::Vocabulary.new("http://www.w3.org/ns/org#hasSite")
VCARD = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
OSPC = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/id/postcodeunit/")
OSDEF = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/ontology/postcode/")
DCTERMS = RDF::Vocabulary.new("http://purl.org/dc/terms/")

# arguments are the graph to add data to and a hash of excel cells, indexed by column header string
def row2rdf(graph,row)
  
  ##### Project #####
  # uri: use TSBProjectNumber
  proj_num = row["TSBProjectNumber"].to_i.to_s
  project_uri = TSB["project/#{proj_num}"]
  project_title = row["ProjectTitle"]
  
  #type, label, description
  graph << [project_uri, RDF.type, TSBDEF.Project]
  graph << [project_uri, RDFS.label, RDF::Literal.new(project_title)]
  
  description = row["PublicDescription"]
  
  # clean up description - replace double line breaks with space chars. 
  description.gsub!(/\n\n/,' ')
  graph << [project_uri,DCTERMS.description, RDF::Literal.new(description)]

  
  ##### Organization ####
  # uri: use urlified name
  org_name = row["ParticipantName"]
  urlified_org_name = urlify(org_name)
  org_uri = TSB["organization/#{urlified_org_name}"]
  
  graph << [org_uri, RDF.type, TSBDEF.Organization]
  graph << [org_uri, RDFS.label, RDF::Literal.new(org_name)]
  
  # address
  # TODO: check whether any org appears in the spreadsheet with more than one different address.
  site_uri = TSB["organization/#{urlified_org_name}/site"]
  address_uri = TSB["organization/#{urlified_org_name}/address"]
  graph << [org_uri, ORG.hasSite, site_uri]
  graph << [site_uri, RDF.type, ORG.Site]
  graph << [site_uri, RDFS.label, RDF::Literal.new("Site of #{org_name}")]
  graph << [site_uri, ORG.siteAddress, address_uri]
  graph << [address_uri, RDF.type, VCARD.Address]
  graph << [address_uri, RDFS.label, RDF::Literal.new("Site address of #{org_name}")]
  # clean up the address cell of the spreadsheet, removing line breaks
  address = row["Address"]
  cleaned_address = address.gsub(/\n/,', ')
  graph << [address_uri, VCARD["street-address"],RDF::Literal.new(cleaned_address)]
  graph << [address_uri, VCARD.locality, RDF::Literal.new(row["Town"])]
  graph << [address_uri, VCARD.region,RDF::Literal.new(row["County"])]
  graph << [address_uri, VCARD["postal-code"],RDF::Literal.new(row["Postcode"])]
  
  
  # postcode - connect to OS URI - what should the subject be? the organization? the site?
  pc = row["Postcode"].gsub(/ /,'') # remove spaces
  pc_uri = OSPC[pc]
  graph << [site_uri, OSDEF.postcode, pc_uri]
  
  # company number - connect to OpenCorporates and Companies House
  
  
  # Grant
  grant_uri = TSB["grant/#{proj_num}/#{urlified_org_name}"]
  
  graph << [grant_uri, RDF.type, TSBDEF.Grant]
  graph << [grant_uri, RDFS.label, RDF::Literal.new("Grant for #{org_name}, project: #{project_title}")]
  
  graph << [grant_uri, TSBDEF.offerCost, RDF::Literal.new(row["OfferCost"].to_i)]
  graph << [grant_uri, TSBDEF.offerGrant, RDF::Literal.new(row["OfferCost"].to_i)]
  graph << [grant_uri, TSBDEF.offerPercentage, RDF::Literal.new(row["OfferRateOfGrant"])]
  graph << [grant_uri, TSBDEF.paymentsToDate, RDF::Literal.new(row["PaymentsToDate"].to_i)]
  
  
  ##### connections #####
  
  # org - project (2 way)
  graph << [org_uri, TSBDEF.participatesIn, project_uri]
  graph << [project_uri, TSBDEF.hasParticipant,org_uri]
  if row["IsLead"] && row["IsLead"] == "Lead"
    graph << [org_uri, TSBDEF.isLeaderOf, project_uri]
    graph << [project_uri, TSBDEF.hasLeader, org_uri]
  end
  
  # grant - org
  graph << [grant_uri, TSBDEF.paidTo, org_uri]
  
  # grant - project
  graph << [grant_uri, TSBDEF.supports, project_uri]
  graph << [project_uri, TSBDEF.supportedBy, grant_uri]
  
  

  
  return graph
end