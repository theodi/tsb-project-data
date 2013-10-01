class Team
  include TsbResource
  
  rdf_type Vocabulary::TSBDEF["Team"]
  
  TEAM_CODES = {
    "Design" => "DSGN",
    "Emerging Technologies and Industries" => "ETI",
    "High Value Services" => "HVS",
    "Creative Industries" => "CRIN",
    "Digital Service" => "DIGS",
    "ICTomorrow" => "ICTM",
    "Internet of Things" => "IOT",
    "Energy" => "ENRG",
    "Assisted Living" => "ASSL",
    "Detection and Identification of Infectious Agents" => "DIIA",
    "Stratified Medicine" => "STMD",
    "High Value Manufacturing" => "HIVM",
    "Industrial Biotechnology" => nil,
    "Space and Satellite" => "SPAS",
    "Future Cities" => "FTCT",
    "Low Impact Buildings" => "LIBG",
    "Resource Efficiency" => "RSEF",
    "Sustainable Agriculture and Food" => "SAF",
    "Water Export" => "WTEX",
    "Bioscience" => "BIO",
    "Electronics Photonics and Electrical Systems" => "EPES",
    "Information and Communication Technology" => "ICT",
    "Advanced Materials" => "ADVM",
    "Aerospace" => "AERO",
    "Integrated Transport" => "ITRAN",
    "Low Carbon Vehicles" => "LCV",
    "General" => "general",
    "Materials" => "materials",
    "HVM" => "HIVM",
    "EPES" => "EPES",
    "Transport" => "transport",
    "ICT" => "ICT",
    "Sustainability" => "sustainability",
    "Biosciences" => "BIO",
    "Sustainable Agriculture & Food" => "SAF",
    "Centres" => "centres",
    "Energy" => "energy",
    "Healthcare" => "healthcare",
    "Space" => "space"
  }
end

