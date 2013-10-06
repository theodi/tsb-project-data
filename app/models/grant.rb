# Note a grant is paid to one org for one project
class Grant
  include TsbResource # some common (RDF-related) stuff

  rdf_type Vocabulary::TSBDEF.Grant

  # literals (label comes from tsb resource)
  field :offer_cost, Vocabulary::TSBDEF.offerCost, datatype: RDF::XSD.integer
  field :offer_grant, Vocabulary::TSBDEF.offerGrant, datatype: RDF::XSD.integer
  field :offer_percentage, Vocabulary::TSBDEF.offerPercentage, datatype: RDF::XSD.decimal
  field :payments_to_date, Vocabulary::TSBDEF.paymentsToDate, datatype: RDF::XSD.decimal

  # links
  linked_to :paid_to_organization, Vocabulary::TSBDEF.paidTo, class_name: 'Organization'
  linked_to :supports_project, Vocabulary::TSBDEF.supports, class_name: 'Project'

end
