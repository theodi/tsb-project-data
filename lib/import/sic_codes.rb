module Import
  module SicCodes

# create concept scheme for enterprise sizes
    def self.create_data
      output_file = File.join(Rails.root, 'data', 'output-data', 'sic_codes.nt')
      input_file = input_file = File.join(Rails.root, 'data', 'input-data', 'sic2007.xlsx')

      excel = Roo::Excelx.new(input_file)

      # the hierarchy is:
      #  Section/Division/Group/Class/Sub-class
      # in the spreadsheet, the code appears in column A/C/E/G/I for the levels above, with the label
      #   in the column after the code
      #

      # hash of tripod resources, indexed by slug
      resources = {}
      current_section = nil
      current_division = nil
      current_group = nil
      current_class = nil

      for i in 4..excel.last_row
        r = excel.row(i).compact # gets row as array, then strip all nil values
        if r.length == 2
          code = r.first.strip
          desc = r.last.strip
          if code.length == 1
            # section
            slug = code
            current_section = slug
            current_division = nil
            current_group = nil
            current_class = nil
          elsif code.length == 2
            # division
            slug = code
            current_division = slug
            current_group = nil
            current_class = nil
          elsif code.length == 4
            # group eg 07.1
            slug = code
            current_group = slug
            current_class = nil
          elsif code.length == 5
            # class eg 10.12
            slug = code.sub(/\./,'') + "0"
            current_class = slug

          elsif code.length == 7
            # sub-class eg 05.10/1
            slug = code.sub(/\./,'')
            slug = slug.sub(/\//,'')

          else
            raise "unexpected format of code"
          end
          sic_uri = Vocabulary::TSBDEF["concept/sic/#{slug}"]
          s = SicClass.new(sic_uri)
          resources[slug] = s
          s.code = code
          s.definition = desc
          s.label = "SIC #{code} #{desc}"
          # should add a datatype to notation values
          puts i
          puts code
          puts current_section
          puts current_division
          puts current_group
          puts current_class
          puts "--------"

          s.notation = slug
          if code.length == 1
            # section
            # at top of tree, don't add relations to others
            # specify as top concept
            s.top_concept_of = s.resource_concept_scheme_uri

          elsif code.length == 2
            # division
            parent = resources[current_section]
            s.broader = parent.uri
            s.sic_section = parent
            parent.narrower << s.uri

          elsif code.length == 4
            # group eg 07.1
            parent = resources[current_division]
            s.broader = parent.uri
            s.sic_division = parent
            s.sic_section = resources[current_section]
            parent.narrower << s.uri

          elsif code.length == 5
            # class eg 10.12
            parent = resources[current_group]
            s.broader = parent.uri
            s.sic_group = parent
            s.sic_division = resources[current_division]
            s.sic_section = resources[current_section]
            parent.narrower << s.uri


          elsif code.length == 7
            # sub-class eg 05.10/1
            parent = resources[current_class]
            s.broader = parent.uri
            s.sic_group = parent
            s.sic_division = resources[current_division]
            s.sic_section = resources[current_section]
            s.sic_class = resources[current_class]
            parent.narrower << s.uri
          else
            raise "unexpected format of code"
          end
        end

      end # loop over rows
      graph = RDF::Graph.new
      # add statements to graph
      resources.each_value do |resource|
        resource.repository.each_statement {|s| graph << s}
      end

      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}
      puts "created #{output_file}"


    end # create_date method

  end

end