class Organization

  include TsbResource

  graph_uri TsbProjectData::DATA_GRAPH
  rdf_type Vocabulary::TSBDEF.Organization

  # literals
  field :label, RDF::RDFS.label

  # uris
  field :leads_project_uri, Vocabulary::TSBDEF.isLeaderOf, is_uri: true
  field :participates_in_project_uri, Vocabulary::TSBDEF.isLeaderOf, is_uri: true, multivalued: true


end