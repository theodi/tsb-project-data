module Import
  module CostCategories


# create concept scheme for enterprise sizes
    def self.create_data
      output_file = File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'cost_categories.nt')

      graph = RDF::Graph.new


      options = {
        "Industrial" => "A cost category for industry-led projects.",
        "Academic" => "A cost category for academic-led projects."
      }

      options.each_pair do |label,desc|
        e = CostCategory.new(Vocabulary::TSBDEF["concept/cost-category/#{Urlify::urlify(label)}"])
        e.label = label
        e.definition = desc
        e.repository.each_statement {|s| graph << s}
      end

      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}

    end
  end
end