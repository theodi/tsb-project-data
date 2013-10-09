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
  
  BUDGET_AREA_COMMENTS = {
    "Development" => "A TSB Programme underpinning other programmes and with a focus on emerging technologies",
    "Digital" => "A TSB Programme with a focus on exploiting data,new value models, resilient and interoperable digital systems, linking services to customers, and supporting the implementation of the Government's Information Economy Industrial Strategy",
    "Energy" => "A TSB Programme with a focus on new energy technologies that help solve the challenges of sustainability, security and affordability of supply and supporting the implementation of the Government's industrial strategy for nuclear, oil and gas, and offshore wind.",
    "Healthcare" => "A TSB Programme with a focus on better disease detection, prevention and management, tailored treatments for disease; potential cures and supporting the implementation of the Government's Life Sciences Strategy",
    "Manufacturing" => "A TSB Programme with a focus on resource efficiency, manufacturing systems, integration of new materials, manufacturing processes, amd new business models.",
    "Space" => "A TSB Programme with a focus on satellite data and space-based satellite systems, national and European space programmes, and demonstration.",
    "Sustainability" => "A TSB Programme underpinning other programmes  and with a focus on built environment, agriculture and food",
    "Technology" => "A TSB Programme underpinning other programmes  and with a focus on enabling technologies",
    "Transport" => "A TSB Programme with a focus on integrated transport systems, low carbon vehicles, rail systems, marine vessel efficiency, aerospace  and supporting the implementation of the Government's strategies for the automotive and aerospace industries, including the delivery of the Aerospace Technology Institute",
    "TSB Programmes" => "All TSB Programmes - a category for those competitions that have not been assigned a specific budgety area"
  }
end