class Region
  include TsbResource

  rdf_type RDF::URI.new('http://statistics.data.gov.uk/def/statistical-geography')
  graph_uri "http://#{PublishMyData.local_domain}/graph/regions"

end