module Import
  class Loader

    extend Urlify
    extend RowToRdf

    # note:
    # vocabularies now defined in config/initializers, in the Vocabulary namespace

    INPUT_FILE = File.join(Rails.root, 'data', 'input-data', 'datatest.xlsx')
    OUTPUT_FILE = File.join(Rails.root, 'data', 'datasets', 'tsb-projects-data', 'data.nt')

    def self.create_data_file

      excel = Roo::Excelx.new(INPUT_FILE)

      # take a copy of the header row for easy reference
      headers = excel.row(1)

      
      # hash of all resources - will build it up gradually from spreadsheet then serialize them at the end
      # the key is the URI of the resource
      resources = {}
      
      for i in 2..excel.last_row
        # make a hash of header names to cell contents for this row
        row = {}
        excel.row(i).each_with_index{|item,index| row[headers[index]] = item}
        row2rdf(resources,row)
      end

      # write out output
      graph = RDF::Graph.new
      # add statements to graph
      resources.each_value do |resource|
        resource.repository.each_statement {|s| graph << s}
      end
  
      
      
      File.open(OUTPUT_FILE,'w') {|f| f << graph.dump(:ntriples)}

      puts "created #{OUTPUT_FILE}"
    end

  end
end