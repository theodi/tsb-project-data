class Project

  include TsbResource # some common (RDF-related) stuff
  include ProjectSearch # for elastic search

  rdf_type Vocabulary::TSBDEF.Project

  # literals (label comes from tsb resource)
  field :description, Vocabulary::DCTERMS.description
  field :project_number, Vocabulary::TSBDEF.projectNumber

  # links
  linked_to :leader, Vocabulary::TSBDEF.hasLeader, class_name: 'Organization'

  # Note a grant is paid to one org for one project
  linked_to :supported_by, Vocabulary::TSBDEF.supportedBy, class_name: 'Grant', multivalued: true
  linked_to :participants, Vocabulary::TSBDEF.hasParticipant, class_name: 'Organization', multivalued: true

  linked_to :competition, Vocabulary::TSBDEF.competition
  linked_to :project_status, Vocabulary::TSBDEF.projectStatus, class_name: 'ProjectStatus'
  linked_to :duration, Vocabulary::TSBDEF.projectDuration, class_name: 'ProjectDuration'
  linked_to :cost_category, Vocabulary::TSBDEF.costCategory

  def offer_cost_sum
    supported_by.sum(&:offer_cost).to_f
  end

  def offer_grant_sum
    supported_by.sum(&:offer_grant).to_f
  end

  def payments_to_date_sum
    supported_by.sum(&:payments_to_date).to_f
  end

  def offer_cost_sum_for_organization(organization)
    grants_for_organization(organization).resources.sum(&:offer_cost).to_f
  end

  def offer_grant_sum_for_organization(organization)
    grants_for_organization(organization).resources.sum(&:offer_grant).to_f
  end

  def payments_to_date_sum_for_organization(organization)
    grants_for_organization(organization).resources.sum(&:payments_to_date).to_f
  end

  def grants_for_organization(organization)
    Grant
      .where("?uri <#{Vocabulary::TSBDEF.supports}> <#{self.uri}>")
      .where("?uri <#{Vocabulary::TSBDEF.paidTo}> <#{organization.uri}>")
  end
  
  # returns a string containing a csv sparql result (one or more results rows), optionally with a header row
  def data_as_csv(include_headers = true)
    #q = PublishMyData::SparqlQuery.new(all_project_data_query, :request_format => :csv)
    q = PublishMyData::SparqlQuery.new(all_project_data_query)
    result = q.execute
    # if include_headers
    #   output = result.to_s
    # else
    #   csv = CSV.parse(result.to_s)
    #   csv.delete_at(0)
    #   # use \r\n for line break - for Windows friendliness
    #   output = CSV.generate(:row_sep => "\r\n") do |c|
    #     csv.each do |row|
    #       c << row
    #     end
    #   end
    # end
    # return output
  end
  
  def all_project_data_query
    
    "
    PREFIX tsb: <http://tsb-projects.labs.theodi.org/def/>
    PREFIX time: <http://purl.org/NET/c4dm/timeline.owl#>
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX dct: <http://purl.org/dc/terms/>
    PREFIX org: <http://www.w3.org/ns/org#>
    PREFIX vcard: <http://www.w3.org/2006/vcard/ns#>
    PREFIX geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
    PREFIX osgeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>

    select 
    (<#{self.uri}> as ?project_id)
    ?project_name
    ?start_date
    ?end_date
    ?cost_category
    ?project_status
    ?offer_grant
    ?offer_cost
    ?offer_percentage
    ?payments_to_date
    ?activity_code
    ?competition_code
    ?competition_year
    ?product
    ?budget_area
    ?org_id
    ?org_name
    ?company_number
    ?company_type
    ?company_size
    ?sic_code
    ((?leader_id = ?org_id) as ?isLead)
    ?company_lat
    ?company_long
    ?region_id
    ?region
    ?district
    ?street
    ?town
    ?county
    ?postcode
    ?project_desc
    WHERE
    {<#{self.uri}> tsb:hasParticipant ?org_id ;
                   tsb:hasLeader ?leader_id ;
                   rdfs:label ?project_name ;
                   dct:description ?project_desc ;
                   tsb:competition ?comp ;
                   tsb:projectDuration ?d ;
                   tsb:costCategory ?cc ;
                   tsb:projectStatus ?stat ;
                   tsb:supportedBy ?grant .
    ?grant tsb:paidTo ?org_id .
    ?cc rdfs:label ?cost_category .
    ?stat rdfs:label ?project_status .
    ?d time:start ?start_date .
    ?d time:end ?end_date .
    ?org_id rdfs:label ?org_name ;
            tsb:companyNumber ?company_number ;
            tsb:legalEntityForm ?legal_entity_form .
    ?legal_entity_form rdfs:label ?company_type .
    OPTIONAL {
      ?org_id tsb:enterpriseSize ?e_size .
      ?e_size rdfs:label ?company_size .}
    OPTIONAL {
      ?org_id tsb:standardIndustrialClassification ?sic .
      ?sic tsb:sicCode ?sic_code .}
    ?org_id org:hasSite ?site .
    ?site org:siteAddress ?address .
    OPTIONAL {
      ?site geo:lat ?company_lat .
      ?site geo:long ?company_long .}
    ?site tsb:region ?region_id .
    ?region_id rdfs:label ?region .
    OPTIONAL {?site osgeo:district ?district .}
    OPTIONAL {?address vcard:street-address ?street .}
    OPTIONAL {?address vcard:locality ?town .}
    OPTIONAL {?address vcard:region ?county .}
    OPTIONAL {?address vcard:postal-code ?postcode .}
    ?comp tsb:activityCode ?activity_code .
    ?comp tsb:competitionCode ?competition_code .
    ?comp tsb:competitionYear ?competition_year .
    ?comp tsb:product ?prod .
    ?prod rdfs:label ?product .
    OPTIONAL {
      ?comp tsb:budgetArea ?budg_id .
      ?budg_id rdfs:label ?budget_area .}
    ?grant tsb:offerGrant ?offer_grant ;
           tsb:offerCost ?offer_cost ;
           tsb:offerPercentage ?offer_percentage ;
           tsb:paymentsToDate ?payments_to_date .

    }
    "
    
  end

end