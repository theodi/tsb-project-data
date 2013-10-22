module ProjectCsv

  def csv_headers
    query_response = Tripod::SparqlClient::Query.query( Project.all_project_data_query('http://foo'), 'application/sparql-results+json')
    JSON.parse(query_response)["head"]["vars"]
  end

  # this is a class method, so can be called on Tire search results without instantiating a tripod project.
  def csv_data(uri)
    results = Tripod::SparqlClient::Query.select( Project.all_project_data_query(uri) )
    results_array = results.collect do |result|

      row = []

      csv_headers.each do |h|
        if result[h]
          row << result[h]["value"]
        else
          row << ""
        end
      end

      row
    end

    results_array
  end

  def generate_csv(unpaginated_results)
    CSV.generate(:row_sep => "\r\n") do |csv|
      #headers
      csv << Project.csv_headers

      #data
      unpaginated_results.each do |result|
        Project.csv_data(result.uri).each { |row| csv << row }
      end
    end
  end

  def all_project_data_query(uri)

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
    (<#{uri.to_s}> as ?project_id)
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
    (GROUP_CONCAT(?sic_code) as ?sic_codes)
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
    {<#{uri.to_s}> tsb:hasParticipant ?org_id ;
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
            tsb:companyNumber ?company_number .
    OPTIONAL {
      ?org_id tsb:legalEntityForm ?legal_entity_form .
      ?legal_entity_form rdfs:label ?company_type .}
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
    GROUP BY
    ?project_id
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
    ?leader_id
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
    "

  end
end