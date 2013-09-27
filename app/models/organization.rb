class Organization

  include TsbResource

  rdf_type Vocabulary::TSBDEF.Organization

  # TODO: check what predicate Companies House uses to link company to number
  field :company_number, Vocabulary::TSBDEF.companyNumber

  # links
  linked_to :leads_projects, Vocabulary::TSBDEF.isLeaderOf, class_name: 'Project', multivalued: true
  linked_to :participates_in_projects, Vocabulary::TSBDEF.participatesIn, class_name: 'Project', multivalued: true
  linked_to :site, Vocabulary::ORG.hasSite, class_name: 'Site'

  # TODO: update predicate
  linked_to :sic_class, 'http://example.com/sic-class'

  # example of an enterprise size (concept)
  linked_to :enterprise_size, 'http://example.com/enterprise-size'

end