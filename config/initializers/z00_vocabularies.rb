# vocabularies for use in this project.
# Note: PublishMyData.local_domain is set in config/environments/development.rb etc.
module Vocabulary
  FOAF = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")
  POST  = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/id/postcodeunit/")
  STATS   = RDF::Vocabulary.new("http://statistics.data.gov.uk/id/statistical-geography/")
  YEAR  = RDF::Vocabulary.new("http://reference.data.gov.uk/id/year/")
  TSBDEF = RDF::Vocabulary.new("http://#{PublishMyData.local_domain}/def/")
  TSB = RDF::Vocabulary.new("http://#{PublishMyData.local_domain}/id/")
  ORG = RDF::Vocabulary.new("http://www.w3.org/ns/org#hasSite")
  VCARD = RDF::Vocabulary.new("http://www.w3.org/2006/vcard/ns#")
  OSPC = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/id/postcodeunit/")
  OSDEF = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/ontology/postcode/")
  DCTERMS = RDF::Vocabulary.new("http://purl.org/dc/terms/")
  GEO = RDF::Vocabulary.new("http://www.w3.org/2003/01/geo/wgs84_pos#")
  OSGEO = RDF::Vocabulary.new("http://data.ordnancesurvey.co.uk/ontology/admingeo/")
end

