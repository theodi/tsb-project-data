namespace :db do

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

  desc 'replace dataset data'
  task replace_dataset_data: :environment do

    url = "#{TsbProjectData::DATA_ENDPOINT}?graph=#{TsbProjectData::DATA_GRAPH}"
    RestClient::Request.execute(
      :method => :put,
      :url => url,
      :payload => File.read(File.join(Rails.root, 'data', 'datasets', 'projects', 'data.nt')),
      :headers => {content_type: 'text/plain'},
      :timeout => 300
    )
  end

end