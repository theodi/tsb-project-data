module Import
  module PriorityAreas


# create concept scheme for priority areas
    def self.create_data

      input_file = File.join(Rails.root, 'data', 'input-data', 'data-definitions.xlsx')
      output_file = File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'priority_areas.nt')

      excel = Roo::Excelx.new(input_file)
      excel.default_sheet = "Reference Data"

      graph = RDF::Graph.new

      code2uri = {}

      # URI is  /def/concept/priority-area/{code}
      PriorityArea::PRIORITY_AREA_CODES.each_pair do |label,code|
        uri = Vocabulary::TSBDEF["concept/priority-area/#{code}"]
        b = PriorityArea.new(uri)
        b.label = label
        b.definition = PriorityArea::PRIORITY_AREA_COMMENTS[label]
        b.notation = code
        code2uri[code] = b
      end

      for i in 66..90
  # do subareas from spreadsheet

        code = excel.cell(i,2).strip
        label = excel.cell(i,3).strip
        definition = excel.cell(i,4)
        unless code == "ENRG"  # skip duplicate

          p = PrioritySubArea.new(Vocabulary::TSBDEF["concept/priority-area/#{code}"])
          code2uri[code] = p
          p.label = label
          p.notation = code
          p.definition = definition if definition
          # broader/narrower links
          parentlabel = excel.cell(i,5).strip
          parentcode = PriorityArea::PRIORITY_AREA_CODES[parentlabel]

          parent = code2uri[parentcode]
          p.broader = parent.uri
          parent.narrower = parent.narrower.push(p.uri)

        end




      end

      # output the data
      code2uri.each_value do |p|
        p.repository.each_statement {|s| graph << s}
      end


      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}

    end
  end
end