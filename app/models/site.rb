class Site

  include TsbResource

  rdf_type Vocabulary::ORG.Site

  # literals (label comes from tsb resource)
  field :lat, Vocabulary::GEO.lat, datatype: RDF::XSD.decimal
  field :long, Vocabulary::GEO.long, datatype: RDF::XSD.decimal
  field :district, Vocabulary::OSGEO.district, is_uri: true
  field :postcode, Vocabulary::OSDEF.postcode, is_uri: true

  # links
  linked_to :address, Vocabulary::ORG.siteAddress, class_name: 'Address'
  linked_to :region, Vocabulary::TSBDEF.region, class_name: 'Region'


end