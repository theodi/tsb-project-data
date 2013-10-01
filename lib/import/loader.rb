module Import
  class Loader

    extend Urlify
    extend RowToRdf

    # note:
    # vocabularies now defined in config/initializers, in the Vocabulary namespace

    INPUT_FILE = File.join(Rails.root, 'data', 'input-data', 'datatest1000.xlsx')
    OUTPUT_FILE = File.join(Rails.root, 'data', 'datasets', 'tsb-projects-data', 'data.nt')

    # parses the excel file, and creates an ntriples version of the data.
    # returns a hash of resources created in the process.
    def self.parse_excel_file

      excel = Roo::Excelx.new(INPUT_FILE)

      # take a copy of the header row for easy reference
      headers = excel.row(1)


      # hash of all resources - will build it up gradually from spreadsheet then serialize them at the end
      # the key is the URI of the resource
      resources = {}
      sic_list = []

      for i in 2..10 #2..excel.last_row
        puts "starting row #{i}"
        # make a hash of header names to cell contents for this row
        row = {}
        excel.row(i).each_with_index{|item,index| row[headers[index]] = item}
        row2rdf(resources,row)
      end

      # write out output
      puts "starting output to RDF"
      graph = RDF::Graph.new
      # add statements to graph
      resources.each_value do |resource|
        resource.repository.each_statement {|s| graph << s}
      end

      File.open(OUTPUT_FILE,'w') {|f| f << graph.dump(:ntriples)}
      puts "created #{OUTPUT_FILE}"

      return resources
    end

  end
end