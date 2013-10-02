module Import
  module ProjectStatuses
    

# create concept scheme for enterprise sizes
    def self.create_data
      output_file = File.join(Rails.root, 'data', 'output-data', 'project_statuses.nt')

      graph = RDF::Graph.new
      
      
      options = {
        "Closed" => "The project is finished.",
        "Live" => "The project is in progress.",
        "Final claim" => "The final claim for the project has been submitted."
      }
      
      options.each_pair do |label,desc|
        e = ProjectStatus.new(Vocabulary::TSBDEF["concept/project-status/#{Urlify::urlify(label)}"])
        e.label = label
        e.definition = desc
        e.repository.each_statement {|s| graph << s}

      end
      
 
      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}


    end
  end
end