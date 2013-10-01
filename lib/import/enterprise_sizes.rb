module Import
  module EnterpriseSizes

# create concept scheme for enterprise sizes
    def self.create_data
      output_file = File.join(Rails.root, 'data', 'output-data', 'enterprise_sizes.nt')

      graph = RDF::Graph.new
      # concept scheme

      options = {
        "large" => "Describes a company with more than 250 employees.",
        "medium" => "Describes a company with between 51 and 250 employees.",
        "small" => "Describes a company with between 11 and 50 employees.",
        "micro" => "Describes a company with up to 10 employees.",
        "academic" => "Refers to an academic institution where the size of the organization is not specified"
      }
      # options are large, medium, small, micro, academic
      options.each_pair do |label,desc|
        e = EnterpriseSize.new(Vocabulary::TSBDEF["concept/enterprise-size/#{label}"])
        e.label = label
        e.definition = desc
        e.repository.each_statement {|s| graph << s}

      end


      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}


    end
  end
end