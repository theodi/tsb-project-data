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
    self.sic_section.nil?
  end

  def is_division?
    self.sic_division.nil?
  end

  def is_group?
    self.sic_group.nil?
  end

  def is_class?
    self.sic_class.nil?
  end

  def singular_label
    if is_section?
      "SIC Section"
    elsif is_division?
      "SIC Division"
    elsif is_group?
      "SIC Group"
    elsif is_class?
      "SIC Class"
    end
  end

  def subclass_list_label
    if is_section?
      "Divisions in this section"
    elsif is_division?
      "Groups in this division"
    elsif is_group?
      "Classes in this group"
    elsif is_class?
      "Sub-classes"
    end
  end

    def direct_subclasses
    SicClass.where("?uri <#{RDF::SKOS.broader}> <#{self.uri.to_s}>").resources
  end

end