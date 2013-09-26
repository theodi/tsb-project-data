class Site

  include TsbResource

  graph_uri TsbProjectData::DATA_GRAPH
  rdf_type Vocabulary::ORG.Site
  
  # literals
  field :label, RDF::RDFS.label
  field :lat, Vocabulary::GEO.lat
  field :long, Vocabulary::GEO.long
  
  # links
  linked_to :address, Vocabulary::ORG.siteAddress, class_name: 'Address'
  linked_to :region, Vocabulary::TSBDEF.region, class_name: 'Region'
  linked_to :district, Vocabulary::OSGEO.district, class_name: 'District'
  linked_to :postcode, Vocabulary::OSDEF.postcode, class_name: 'Postcode'
  
end