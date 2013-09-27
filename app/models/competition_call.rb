class CompetitionCall

  # Question: should this be a resource in the dataset, or a concept in a scheme?
  include TsbResource

  # TODO: update predicates
  linked_to :team, 'http://example.com/team'
  linked_to :budget_area, 'http://example.com/budget'
  linked_to :product, 'http://exampel.com/product'

end