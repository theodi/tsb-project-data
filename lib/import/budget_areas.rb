module Import
  module BudgetAreas


# create concept scheme for budget areas
    def self.create_data
      output_file = File.join(Rails.root, 'public', 'dumps', 'budget_areas.nt')

      graph = RDF::Graph.new

      # URI should be /id/budget-area/{code}
      BudgetArea::BUDGET_AREA_CODES.each_pair do |label,code|
        uri = Vocabulary::TSB["budget-area/#{code}"]
        b = BudgetArea.new(uri)
        b.label = label
        b.comment = BudgetArea::BUDGET_AREA_COMMENTS[label]
        b.repository.each_statement {|s| graph << s}

      end

      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}

    end
  end
end