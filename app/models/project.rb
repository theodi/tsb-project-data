class Project

  include TsbResource # some common (RDF-related) stuff
  include ProjectSearch # for elastic search

  rdf_type Vocabulary::TSBDEF.Project

  # literals (label comes from tsb resource)
  field :description, Vocabulary::DCTERMS.description
  field :project_number, Vocabulary::TSBDEF.projectNumber

  # links
  linked_to :leader, Vocabulary::TSBDEF.hasLeader, class_name: 'Organization'

  # Note a grant is paid to one org for one project
  linked_to :supported_by, Vocabulary::TSBDEF.supportedBy, class_name: 'Grant', multivalued: true
  linked_to :participants, Vocabulary::TSBDEF.hasParticipant, class_name: 'Organization', multivalued: true

  linked_to :competition, Vocabulary::TSBDEF.competition
  linked_to :project_status, Vocabulary::TSBDEF.projectStatus, class_name: 'ProjectStatus'
  linked_to :duration, Vocabulary::TSBDEF.projectDuration, class_name: 'ProjectDuration'
  linked_to :cost_category, Vocabulary::TSBDEF.costCategory



end