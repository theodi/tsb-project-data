class BudgetArea
  include TsbResource
  rdf_type Vocabulary::TSBDEF["BudgetArea"]
  
  BUDGET_AREA_CODES = {
    "Development" => "DEVL",
    "Digital" => "DIGS",
    "Energy" => "ENRG",
    "Healthcare" => "HLTHCR",
    "Manufacturing" => "MANF",
    "Space" => "SPAC",
    "Sustainability" => "SUST",
    "Technology" => "TECH",
    "Transport" => "TRAN",
    "TSB Programmes" => 'tsb-programmes'
  }
end