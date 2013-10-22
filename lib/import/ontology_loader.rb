module Import
  class OntologyLoader

    def self.prepare_ontology
      input_file = File.join(Rails.root, 'data', 'input-data', 'ontology.xlsx')
      output_file = File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'ontology.nt')

      excel = Roo::Excelx.new(input_file)
      graph = RDF::Graph.new

      ontology_uri = Vocabulary::TSBDEF["ontology"]

#  Classes
      excel.default_sheet = "Classes"
      for i in 2..excel.last_row
        class_uri = Vocabulary::TSBDEF[excel.cell(i,1)]
        graph << [class_uri, RDF.type, RDF::RDFS["Class"]]
        graph << [class_uri, RDF.type, RDF::OWL["Class"]]
        graph << [class_uri, RDF::RDFS.isDefinedBy, ontology_uri]
        graph << [class_uri, RDF::RDFS.label, RDF::Literal.new(excel.cell(i,2))]
        graph << [class_uri, RDF::RDFS.comment, RDF::Literal.new(excel.cell(i,3))]
        if excel.cell(i,4)
          obj = excel.cell(i,4)
          if obj.starts_with?('http://')
            obj_uri = RDF::URI.new(obj)
          else
            obj_uri = Vocabulary::TSBDEF[obj]
          end
          graph << [class_uri, RDF::RDFS.subClassOf, RDF::URI.new(obj_uri)]
        end


      end

# Properties
      excel.default_sheet = "Properties"
      for i in 2..excel.last_row
        property_uri = Vocabulary::TSBDEF[excel.cell(i,1)]
        graph << [property_uri, RDF.type, RDF.Property]
        graph << [property_uri, RDF::RDFS.label, RDF::Literal.new(excel.cell(i,2))]
        graph << [property_uri, RDF::RDFS.isDefinedBy, ontology_uri]
        graph << [property_uri, RDF::RDFS.comment, RDF::Literal.new(excel.cell(i,3))]
        if excel.cell(i,4)
          obj = excel.cell(i,4)
          if obj.starts_with?('http://')
            obj_uri = RDF::URI.new(obj)
          else
            obj_uri = Vocabulary::TSBDEF[obj]
          end
          graph << [property_uri, RDF::RDFS.subPropertyOf, RDF::URI.new(obj_uri)]
        end
        if excel.cell(i,5)
          obj = excel.cell(i,5)
          if obj.starts_with?('http://')
            obj_uri = RDF::URI.new(obj)
          else
            obj_uri = Vocabulary::TSBDEF[obj]
          end
          graph << [property_uri, RDF::RDFS.domain, RDF::URI.new(obj_uri)]
        end
        if excel.cell(i,6)
          obj = excel.cell(i,6)
          if obj.starts_with?('http://')
            obj_uri = RDF::URI.new(obj)
          else
            obj_uri = Vocabulary::TSBDEF[obj]
          end
          graph << [property_uri, RDF::RDFS.range, RDF::URI.new(obj_uri)]
        end



      end

      File.open(output_file, "w") {|f| f << graph.dump(:ntriples)}

    end

  end
end