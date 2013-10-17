class SicClass
  include Concept
  
  concept_scheme_uri Vocabulary::TSBDEF["concept-scheme/sic"]
  
  field :code, Vocabulary::TSBDEF.sicCode
  field :top_concept_of, RDF::SKOS.topConceptOf, is_uri: true
  
  linked_to :sic_section, Vocabulary::TSBDEF.sicSection, class_name: 'SicClass'
  linked_to :sic_division, Vocabulary::TSBDEF.sicDivision, class_name: 'SicClass'
  linked_to :sic_group, Vocabulary::TSBDEF.sicGroup, class_name: 'SicClass'
  linked_to :sic_class, Vocabulary::TSBDEF.sicClass, class_name: 'SicClass'

  def is_section?
    sic_section.nil?
  end
end