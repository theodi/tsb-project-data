module Import
  module EnterpriseSizes

# create concept scheme for enterprise sizes
    def self.create_data
      output_file = File.join(Rails.root, 'data', 'datasets', 'tsb-projects-data', 'enterprise_sizes.nt')
  
      graph = RDF::Graph.new
      # concept scheme
      
      e = EnterpriseSize.new(Vocabulary::TSBDEF["concept/enterprise-size/large"])
      # e.label
      #      e.description
      
      e.repository.each_statement {|s| graph << s}
      
      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}
      
      
    end
  end
end