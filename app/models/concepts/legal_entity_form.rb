class LegalEntityForm
  include Concept
  concept_scheme_uri Vocabulary::TSBDEF["concept-scheme/legal-entity-forms"]
  
  LEGAL_ENTITY_FORMS = {
    "Limited Company" => "limited-company",
    "Higher Education" => "higher-education",
    "Limited by Guarantee" => "limited-by-guarantee",
    "Research and Technology Organisation (RTO)" => "RTO",
    "Trade Association" => "trade-association",
    "Unlimited Company" => "unlimited-company",
    "Public Limited Company" => "public-limited-company",
    "Public Sector" => "public-sector"
  }
end