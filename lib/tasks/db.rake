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
  end

  desc 'replace supporting data'
  task replace_supporting_data: :environment do
    replace_graph(Region.get_graph_uri, 'regions.nt')
    replace_graph(Product.get_graph_uri, 'products.nt')
    replace_graph(EnterpriseSize.get_graph_uri, 'enterprise_sizes.nt')
    replace_graph(LegalEntityForm.get_graph_uri, 'legal_entity_forms.nt')
    replace_graph(ProjectStatus.get_graph_uri, 'project_statuses.nt')
  end

  desc 'replace project dataset data.'
  task replace_project_data: :environment do
    replace_graph(TsbProjectData::DATA_GRAPH, 'project_data.nt')
  end



end