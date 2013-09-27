class Grant
  include Tripod::Resource

  rdf_type Vocabulary::TSBDEF.Grant

  # literals
  field :label, RDF::RDFS.label
  field :offer_cost, Vocabulary::TSBDEF.offerCost, datatype: RDF::XSD.integer
  field :offer_grant, Vocabulary::TSBDEF.offerGrant, datatype: RDF::XSD.integer
  field :offer_percentage, Vocabulary::TSBDEF.offerPercentage, datatype: RDF::XSD.decimal
  field :payments_to_date, Vocabulary::TSBDEF.paymentsToDate, datatype: RDF::XSD.integer

  # links
  linked_to :paid_to_organisation, Vocabulary::TSBDEF.paidTo, class_name: 'Organisation'
  linked_to :supports_project, Vocabulary::TSBDEF.paidTo, class_name: 'Project'

end
