class CompetitionCall

  # Question: should this be a resource in the dataset, or a concept in a scheme?
  include TsbResource

  rdf_type Vocabulary::TSBDEF.CompetitionCall
  
  field :competition_code, Vocabulary::TSBDEF.competitionCode
  field :competition_year, Vocabulary::TSBDEF.competitionYear, is_uri: true
  
  # TODO: update predicates
  linked_to :team, Vocabulary::TSBDEF.team
  linked_to :budget_area,  Vocabulary::TSBDEF.budgetArea
  linked_to :product,  Vocabulary::TSBDEF.product

end