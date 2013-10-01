class Product

  # Question: should this be a resource in the dataset, or a concept in a scheme?
  include Concept
  
  concept_scheme_uri Vocabulary::TSBDEF["concept-scheme/products"]
  
  PRODUCT_CODES = {
    "Competition" => "CMP",
    "Centre of Excellence" => "COE",
    "Community" => "COM",
    "Legacy" => "LGC",
    "Thematic Competition" => "TCMP",
    "Responsive Competition" => "RCMP",
    "Catalyst" => "CATL",
    "Collaborative Research and Development" => "CRD",
    "European" => "EU",
    "Fast Track" => "FT",
    "Feasibility Study" => "FS",
    "IC Tomorrow" => "ICTom",
    "Innovation Voucher" => "IV",
    "Knowledge Transfer Partnership" => "KTP",
    "Large Scale Demonstrator" => "Large",
    "Launchpad" => "LP",
    "Procurement" => "PROC",
    "Small Business Research Initiative" => "SBRI",
    "SMART" => "GRD",
    "Catapult" => "CATP",
    "Event" => "EVENT",
    "Knowledge Transfer Network" => "KTN",
    "Special Interest Group" => "SIG",
    "Networking" => "NET",
    "Mission" => "MIS",
    "Workshop" => "WKS",
    "Department of Trade and Industry" => "DTI",
    "Regional Development Agency" => "RDA",
    "Future Cities Demonstrator" => "FCD",
    "Proof of Market" => "POM",
    "Proof of Concept" => "POC",
    "Development of Prototype" => "DOP"
  }

end
