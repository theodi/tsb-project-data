namespace :db do

  def replace_graph(graph_uri, filename, content_type='text/plain')

    puts "loading #{filename} -> #{graph_uri}"
    url = "#{TsbProjectData::DATA_ENDPOINT}?graph=#{graph_uri}"

    RestClient::Request.execute(
      :method => :put,
      :url => url,
      :payload => File.read(File.join(Rails.root, 'data', 'output-data', filename)),
      :headers => {content_type: content_type},
      :timeout => 300
    )
  end

  desc 'Clean Tripod data'
  task clean: :environment do
    Tripod::SparqlClient::Update.update('
      # delete from default graph:
      DELETE {?s ?p ?o} WHERE {?s ?p ?o};
      # delete from named graphs:
      DELETE {graph ?g {?s ?p ?o}} WHERE {graph ?g {?s ?p ?o}};
    ')
  end

  desc 'replace dataset metadata'
  task replace_dataset_metadata: :environment do

    dataset = PublishMyData::Dataset.new(
      "http://#{PublishMyData.local_domain}/data/#{TsbProjectData::DATASET_SLUG}",
      "#{TsbProjectData::DATA_GRAPH}/metadata"
    )

    dataset.title = "TSB Projects Data"
    dataset.label = dataset.title
    dataset.description = "TSB"
    dataset.comment = "TSB Projects Data"
    dataset.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    dataset.data_dump = "http://#{PublishMyData.local_domain}/data/#{TsbProjectData::DATASET_SLUG}/dump"
    dataset.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    dataset.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    dataset.write_predicate("http://publishmydata.com/def/dataset#graph", TsbProjectData::DATA_GRAPH)
    puts dataset.save

    #TODO: datasets for regions and budget areas

  end

  desc 'replace supporting data'
  task replace_supporting_data: :environment do

    replace_graph(Product.get_graph_uri, 'products.nt')
    replace_graph(EnterpriseSize.get_graph_uri, 'enterprise_sizes.nt')
    replace_graph(LegalEntityForm.get_graph_uri, 'legal_entity_forms.nt')
    replace_graph(ProjectStatus.get_graph_uri, 'project_statuses.nt')
    replace_graph(CostCategory.get_graph_uri, 'cost_categories.nt')
    replace_graph(SicClass.get_graph_uri, 'sic_codes.nt')

    # TODO: budget areas and regions need their own dataset metadata.
    replace_graph(Region.get_graph_uri, 'regions.nt')
    replace_graph(BudgetArea.get_graph_uri, 'budget_areas.nt')

    # TODO: add some ontology metadata
    replace_graph(TsbProjectData::ONTOLOGY_GRAPH, 'ontology.nt')
    
    # load external ontologies
    replace_graph(TsbProjectData::ORG_ONTOLOGY_GRAPH, 'org.ttl')
    replace_graph(TsbProjectData::DCTERMS_ONTOLOGY_GRAPH,'dcterms.rdf')
    replace_graph(TsbProjectData::VCARD_ONTOLOGY_GRAPH,'vcard.ttl')
    replace_graph(TsbProjectData::FOAF_ONTOLOGY_GRAPH,'foaf.rdf')
    replace_graph(TsbProjectData::PC_ONTOLOGY_GRAPH,'postcode.owl')
    replace_graph(TsbProjectData::GEO_ONTOLOGY_GRAPH,'wgs84_pos.rdf')
    replace_graph(TsbProjectData::ADMINGEO_ONTOLOGY_GRAPH,'admingeo.ttl')
    replace_graph(TsbProjectData::RDF_ONTOLOGY_GRAPH,'rdf.rdf')
    replace_graph(TsbProjectData::RDFS_ONTOLOGY_GRAPH,'rdfs.rdf')
    replace_graph(TsbProjectData::OWL_ONTOLOGY_GRAPH,'owl.rdf')
    replace_graph(TsbProjectData::SKOS_ONTOLOGY_GRAPH,'skos.rdf')
    replace_graph(TsbProjectData::TIMELINE_ONTOLOGY_GRAPH,'timeline.ttl')
    
    
    
  end

  desc 'replace project dataset data.'
  task replace_project_data: :environment do
    replace_graph(TsbProjectData::DATA_GRAPH, 'project_data.nt')
  end



end