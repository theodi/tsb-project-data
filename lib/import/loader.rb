module Import
  class Loader

    extend RowToRdf

    # parses the excel file, and creates an ntriples version of the data.
    # returns a hash of resources created in the process.
    def self.prepare_project_data(input_filename)

      input_file = File.join(Rails.root, 'data', 'input-data', input_filename)
      output_file = File.join(TsbProjectData::DUMP_OUTPUT_PATH, "project_data-#{DateTime.now.strftime('%Y%m%d')}.nt")

      #sic_hash_file = File.join(Rails.root, 'data', 'sic', 'sic.json')
      org_sic_hash_file = File.join(Rails.root, 'data', 'sic', 'company_to_sic_code.json')

      excel = Roo::Excelx.new(input_file)

      # take a copy of the header row for easy reference
      headers = excel.row(1)

      # hash of all resources - will build it up gradually from spreadsheet then serialize them at the end
      # the key is the URI of the resource
      resources = {}

      #sic_hash = JSON.parse(File.read(sic_hash_file))
      # each entry has company number as key and an array of sic codes as value
      org_sic_hash = JSON.parse(File.read(org_sic_hash_file))


      for i in 2..excel.last_row
        puts "starting row #{i}"
        # make a hash of header names to cell contents for this row
        row = {}
        excel.row(i).each_with_index{|item,index| row[headers[index].strip] = item}
        row2rdf(resources,row,org_sic_hash)
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