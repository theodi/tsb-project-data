class Organization

  include TsbResource

  graph_uri TsbProjectData::DATA_GRAPH
  rdf_type Vocabulary::TSBDEF.Organization

  # literals
  field :label, RDF::RDFS.label
  
  # TODO: check what predicate Companies House uses to link company to number
  field :company_number, Vocabulary::TSBDEF.companyNumber

  # links
  linked_to :leads_projects, Vocabulary::TSBDEF.isLeaderOf, class_name: 'Project', multivalued: true
  linked_to :participates_in_projects, Vocabulary::TSBDEF.participatesIn, class_name: 'Project', multivalued: true
  linked_to :site, Vocabulary::ORG.hasSite, class_name: 'Site'
  

end