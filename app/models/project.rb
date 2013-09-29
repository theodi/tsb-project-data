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

  # Note a grant is paid to one org for one project
  linked_to :supported_by, Vocabulary::TSBDEF.supportedBy, class_name: 'Grant', multivalued: true
  linked_to :participants, Vocabulary::TSBDEF.hasParticipants, class_name: 'Organization', multivalued: true

  # TODO: update predicates on these.
  linked_to :competition_call, 'http://example.com/competition-call'
  linked_to :project_status, 'http://example.com/project-status'



end