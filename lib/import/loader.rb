module Import
  class Loader

    extend Urlify
    extend RowToRdf

    # parses the excel file, and creates an ntriples version of the data.
    # returns a hash of resources created in the process.
    def self.parse_excel_file(input_filename)

      input_file = File.join(Rails.root, 'data', 'input-data', input_filename)
      output_file = File.join(Rails.root, 'data', 'datasets', 'tsb-projects-data', 'data.nt')

      excel = Roo::Excelx.new(input_file)

      # take a copy of the header row for easy reference
      headers = excel.row(1)

      # hash of all resources - will build it up gradually from spreadsheet then serialize them at the end
      # the key is the URI of the resource
      resources = {}
      sic_list = []

      for i in 2..excel.last_row
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

      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}
      puts "created #{output_file}"

      return resources
    end

  end
end