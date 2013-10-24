class Organization

  include TsbResource

  rdf_type Vocabulary::TSBDEF.Organization

  # TODO: check what predicate Companies House uses to link company to number
  field :company_number, Vocabulary::TSBDEF.companyNumber
  field :same_as, RDF::OWL.sameAs, is_uri: true, multivalued: true

  # links
  linked_to :leads_projects, Vocabulary::TSBDEF.isLeaderOf, class_name: 'Project', multivalued: true
  linked_to :participates_in_projects, Vocabulary::TSBDEF.participatesIn, class_name: 'Project', multivalued: true
  linked_to :site, Vocabulary::ORG.hasSite, class_name: 'Site'
  linked_to :legal_entity_form, Vocabulary::TSBDEF.legalEntityForm
  linked_to :enterprise_size, Vocabulary::TSBDEF.enterpriseSize
  linked_to :sic_classes, Vocabulary::TSBDEF.standardIndustrialClassification, class_name: 'SicClass', multivalued: true

  def offer_cost_sum
    grants.resources.sum(&:offer_cost).to_f
  end

  def offer_grant_sum
    grants.resources.sum(&:offer_grant).to_f
  end

  def payments_to_date_sum
    grants.resources.sum{ |p| p.payments_to_date || 0 ).to_f
  end

  def grants
    Grant.where("?uri <#{Vocabulary::TSBDEF.paidTo}> <#{self.uri}>")
  end

  def has_lat_long?
    site.lat.present? && site.long.present?
  end

end