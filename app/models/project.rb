class Project

  include TsbResource # some common (RDF-related) stuff
  include ProjectSearch # for elastic search

  rdf_type Vocabulary::TSBDEF.Project

  # literals
  field :label, RDF::RDFS.label
  field :description, Vocabulary::DCTERMS.description
  field :project_number, Vocabulary::TSBDEF.projectNumber
  field :start_date, Vocabulary::TSBDEF.startDate
  field :end_date, Vocabulary::TSBDEF.endDate

  # links
  linked_to :leader, Vocabulary::TSBDEF.hasLeader, class_name: 'Organization'
  linked_to :supported_by, Vocabulary::TSBDEF.supportedBy, class_name: 'Grant'

  linked_from :participants, :participates_in_projects, class_name: 'Organization'

  # TODO:
  # project -> CompetitionCall
  # Competition -> product, budget area, TSB-team.

end