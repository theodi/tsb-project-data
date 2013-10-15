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

    # main projects data
    projects_dataset = PublishMyData::Dataset.new(
      "http://#{PublishMyData.local_domain}/data/#{TsbProjectData::DATASET_SLUG}",
      "#{TsbProjectData::DATA_GRAPH}/metadata"
    )

    projects_dataset.title = "TSB Projects Data"
    projects_dataset.label = projects_dataset.title
    projects_dataset.description = "TSB"
    projects_dataset.comment = "TSB Projects Data"
    projects_dataset.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    projects_dataset.data_dump = "http://#{PublishMyData.local_domain}/data/#{TsbProjectData::DATASET_SLUG}/dump"
    projects_dataset.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    projects_dataset.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    projects_dataset.write_predicate("http://publishmydata.com/def/dataset#graph", TsbProjectData::DATA_GRAPH)
    projects_dataset.save

    # regions
    regions_dataset = PublishMyData::Dataset.new(
      "http://#{PublishMyData.local_domain}/data/regions",
      "#{Region.get_graph_uri}/metadata"
    )

    regions_dataset.title = "TSB Regions"
    regions_dataset.label = regions_dataset.title

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
  end

  desc 'replace project dataset data.'
  task replace_project_data: :environment do
    replace_graph(TsbProjectData::DATA_GRAPH, 'project_data.nt')
  end



end