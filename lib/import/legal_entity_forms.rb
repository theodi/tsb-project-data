module Import
  module LegalEntityForms

# create concept scheme for enterprise sizes
    def self.create_data
      output_file = File.join(Rails.root, 'data', 'output-data', 'legal_entity_forms.nt')

      graph = RDF::Graph.new
      # concept scheme
      LegalEntityForm::LEGAL_ENTITY_FORMS.each_pair do |label, slug|
        e = LegalEntityForm.new(Vocabulary::TSBDEF["concept/legal-entity-form/#{slug}"])
        e.label = label
        e.repository.each_statement {|s| graph << s}
               
      end
 
      # write graph to file
      File.open(output_file,'w') {|f| f << graph.dump(:ntriples)}


    end
  end
end