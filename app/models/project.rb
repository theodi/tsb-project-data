class Project

  include TsbResource # some common (RDF-related) stuff
  include ProjectSearch # for elastic search

  rdf_type Vocabulary::TSBDEF.Project

  # literals (label comes from tsb resource)
  field :description, Vocabulary::DCTERMS.description
  field :project_number, Vocabulary::TSBDEF.projectNumber
  field :start_date, Vocabulary::TSBDEF.startDate
  field :end_date, Vocabulary::TSBDEF.endDate

  # links
  linked_to :leader, Vocabulary::TSBDEF.hasLeader, class_name: 'Organization'
  linked_to :supported_by, Vocabulary::TSBDEF.supportedBy, class_name: 'Grant'

  # TODO: update predicates on these.
  linked_to :competition_call, 'http://example.com/competition-call'
  linked_to :project_status, 'http://example.com/project-status'

  linked_from :participants, :participates_in_projects, class_name: 'Organization'

end