module Import
  class Loader

    extend Urlify
    extend RowToRdf

    # note:
    # vocabularies now defined in config/initializers, in the Vocabulary namespace

    INPUT_FILE = File.join(Rails.root, 'data', 'input-data', 'datatest.xlsx')
    OUTPUT_FILE = File.join(Rails.root, 'data', 'input-data', 'datatest.nt')

    def self.perform_load

      excel = Roo::Excelx.new(INPUT_FILE)

      # take a copy of the header row for easy reference
      headers = excel.row(1)

      graph = RDF::Graph.new

      for i in 2..excel.last_row
        # make a hash of header names to cell contents for this row
        row = {}
        excel.row(i).each_with_index{|item,index| row[headers[index]] = item}
        row2rdf(graph,row)
      end

      # write out output
      File.open(OUTPUT_FILE,'w') {|f| f << graph.dump(:ntriples)}
    end

  end
end