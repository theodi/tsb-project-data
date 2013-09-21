class Grant
  include Tripod::Resource

  graph_uri TsbProjectData::DATA_GRAPH
  rdf_type Vocabulary::TSBDEF.Grant

  # literals
  field :label, RDF::RDFS.label
  field :offer_cost, Vocabulary::TSBDEF.offerCost, datatype: RDF::XSD.integer
  field :offer_grant, Vocabulary::TSBDEF.offerGrant, datatype: RDF::XSD.integer
  field :offer_percentage, Vocabulary::TSBDEF.offerPercentage, datatype: RDF::XSD.decimal
  field :payments_to_date, Vocabulary::TSBDEF.paymentsToDate, datatype: RDF::XSD.integer

  # uris
  field :paid_to_organisation_uri, Vocabulary::TSBDEF.paidTo, is_uri: true
  field :supports_project_uri, Vocabulary::TSBDEF.supports, is_uri: true

end
