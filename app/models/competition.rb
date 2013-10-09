class Competition

  include TsbResource

  rdf_type Vocabulary::TSBDEF.Competition

  field :competition_code, Vocabulary::TSBDEF.competitionCode
  field :competition_year, Vocabulary::TSBDEF.competitionYear, is_uri: true
  field :activity_code, Vocabulary::TSBDEF.activityCode

  linked_to :team, Vocabulary::TSBDEF.team
  linked_to :budget_area, Vocabulary::TSBDEF.budgetArea
  linked_to :product,  Vocabulary::TSBDEF.product

end