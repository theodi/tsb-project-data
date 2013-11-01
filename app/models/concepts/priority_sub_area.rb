class PrioritySubArea
  include Concept
  concept_scheme_uri Vocabulary::TSBDEF["concept-scheme/priority-areas"]
  
  def initialize(uri, graph_uri=nil)
    super(uri,graph_uri)
    self.rdf_type = self.rdf_type.push(Vocabulary::TSBDEF["PrioritySubArea"])
    self.in_scheme = self.class.resource_concept_scheme_uri
  
  end
  
  PRIORITY_SUB_AREA_CODES = {
    "Advanced Materials" => "ADV_MAT",
    "Aerospace" => "AERO",
    "Assisted Living" => "ASS_LIV",
    "Bioscience" => "BIO_SCI",
    "Creative Industries" => "CRE_IND",
    "Design" => "DSGN",
    "Detection and Identification of Infectious Agents" => "DET_IIA",
    "Digital Service" => "DIGS",
    "Electronics Photonics & Electrical Systems" => "E_P_E_S",
    "Emerging Technologies and Industries" => 'ETI',
    "Future Cities" => "FTCT",
    "High Value Manufacturing" => "HIVAMAN",
    "High Value Services" => "HVS",
    "ICTomorrow" => "ICTM",
    "Industrial Biotechnology" => "IBIOT",
    "Information and Communication Technology" => "INFO_CT",
    "Integrated Transport" => "ITRAN",
    "Internet of Things" => "IOT",
    "Low Carbon Vehicles" => "LOC_VEH",
    "Low Impact Buildings" => "LOW_IMP",
    "Resource Efficiency" => "RSEF",
    "Space and Satellite" => "SPAS",
    "Stratified Medicine" => "STMD",
    "Sustainable Agriculture & Food" => "Sustainable Agriculture & Food"
  }
end