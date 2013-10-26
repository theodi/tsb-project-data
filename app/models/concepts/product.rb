class Product

  # Question: should this be a resource in the dataset, or a concept in a scheme?
  include Concept
  
  concept_scheme_uri Vocabulary::TSBDEF["concept-scheme/products"]
  
  field :top_concept_of, RDF::SKOS.topConceptOf, is_uri: true
  
  PRODUCT_CODES = {
    "Competition" => "CMP",
    "Centre of Excellence" => "COE",
    "Centres" => "COE",
    "Centre" => "COE",
    "Community" => "COM",
    "Legacy" => "LGC",
    "Thematic Competition" => "TCMP",
    "Responsive Competition" => "RCMP",
    "Catalyst" => "CATL",
    "Collaborative Research and Development" => "CRD",
    "CRD" => "CRD",
    "European" => "EU",
    "Fast Track" => "FT",
    "Feasibility Study" => "FS",
    "IC Tomorrow" => "ICTom",
    "Innovation Voucher" => "IV",
    "Knowledge Transfer Partnership" => "KTP",
    "KTP" => "KTP",
    "Large Scale Demonstrator" => "LP",
    "Large" => "LP",
    "Launchpad" => "LCHPD",
    "Procurement" => "PROC",
    "Small Business Research Initiative" => "SBRI",
    "SBRI" => "SBRI",
    "SMART" => "GRD",
    "Smart" => "GRD",
    "Catapult" => "CATP",
    "Event" => "EVENT",
    "Knowledge Transfer Network" => "KTN",
    "KTN" => "KTN",
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

