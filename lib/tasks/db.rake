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
    projects_dataset.comment = "Etiam vitae nisi elit. Cras ultricies risus a scelerisque gravida. Aliquam rutrum fermentum venenatis. Nullam ac est in purus semper gravida. Vestibulum eleifend eu risus et viverra."
    projects_dataset.description = "
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus in molestie sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent consequat quam a erat aliquam tincidunt. Nulla convallis, felis a bibendum pellentesque, leo sem auctor est, ac porttitor elit arcu non ligula. Quisque felis arcu, ultricies a libero iaculis, facilisis ultricies nisl. Vestibulum volutpat ac tellus sit amet cursus. Etiam cursus iaculis pretium. Praesent pulvinar orci eget arcu tincidunt, porttitor sollicitudin augue gravida. Etiam id cursus felis. Praesent vulputate sodales sapien a scelerisque. Integer posuere est eget arcu pretium, consectetur eleifend lacus adipiscing. Phasellus egestas pretium tortor, vel mollis nisl luctus et. Sed cursus ultrices odio, vitae porta leo posuere id.

Nulla facilisi. Nam metus purus, aliquam at cursus vel, mattis in leo. Etiam vitae nisi elit. Cras ultricies risus a scelerisque gravida. Aliquam rutrum fermentum venenatis. Nullam ac est in purus semper gravida. Vestibulum eleifend eu risus et viverra. Praesent mauris massa, adipiscing nec nulla sagittis, cursus imperdiet nunc. Duis eu massa vitae turpis vulputate cursus gravida a lorem.
    "
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
      Region.get_graph_uri.to_s.gsub("/graph/", "/data/"),
      "#{Region.get_graph_uri}/metadata"
    )

    regions_dataset.title = "TSB Regions"
    regions_dataset.label = regions_dataset.title
    regions_dataset.comment = "Nulla facilisi. Nam metus purus, aliquam at cursus vel, mattis in leo"
    regions_dataset.description = "
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus in molestie sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent consequat quam a erat aliquam tincidunt. Nulla convallis, felis a bibendum pellentesque, leo sem auctor est, ac porttitor elit arcu non ligula. Quisque felis arcu, ultricies a libero iaculis, facilisis ultricies nisl. Vestibulum volutpat ac tellus sit amet cursus. Etiam cursus iaculis pretium. Praesent pulvinar orci eget arcu tincidunt, porttitor sollicitudin augue gravida. Etiam id cursus felis. Praesent vulputate sodales sapien a scelerisque. Integer posuere est eget arcu pretium, consectetur eleifend lacus adipiscing. Phasellus egestas pretium tortor, vel mollis nisl luctus et. Sed cursus ultrices odio, vitae porta leo posuere id.

Nulla facilisi. Nam metus purus, aliquam at cursus vel, mattis in leo. Etiam vitae nisi elit. Cras ultricies risus a scelerisque gravida. Aliquam rutrum fermentum venenatis. Nullam ac est in purus semper gravida. Vestibulum eleifend eu risus et viverra. Praesent mauris massa, adipiscing nec nulla sagittis, cursus imperdiet nunc. Duis eu massa vitae turpis vulputate cursus gravida a lorem.
    "
    regions_dataset.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    regions_dataset.data_dump = "http://#{PublishMyData.local_domain}/data/#{Region::DATASET_SLUG}/dump"
    regions_dataset.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    regions_dataset.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    regions_dataset.write_predicate("http://publishmydata.com/def/dataset#graph", Region.get_graph_uri)
    regions_dataset.save


    # budget areas
    ba_dataset = PublishMyData::Dataset.new(
      BudgetArea.get_graph_uri.to_s.gsub("/graph/", "/data/"),
      "#{Region.get_graph_uri}/metadata"
    )

    ba_dataset.title = "TSB Budget Areas"
    ba_dataset.label = regions_dataset.title
    ba_dataset.comment = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus in molestie sapien. "
    ba_dataset.description = "
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus in molestie sapien. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent consequat quam a erat aliquam tincidunt. Nulla convallis, felis a bibendum pellentesque, leo sem auctor est, ac porttitor elit arcu non ligula. Quisque felis arcu, ultricies a libero iaculis, facilisis ultricies nisl. Vestibulum volutpat ac tellus sit amet cursus. Etiam cursus iaculis pretium. Praesent pulvinar orci eget arcu tincidunt, porttitor sollicitudin augue gravida. Etiam id cursus felis. Praesent vulputate sodales sapien a scelerisque. Integer posuere est eget arcu pretium, consectetur eleifend lacus adipiscing. Phasellus egestas pretium tortor, vel mollis nisl luctus et. Sed cursus ultrices odio, vitae porta leo posuere id.

Nulla facilisi. Nam metus purus, aliquam at cursus vel, mattis in leo. Etiam vitae nisi elit. Cras ultricies risus a scelerisque gravida. Aliquam rutrum fermentum venenatis. Nullam ac est in purus semper gravida. Vestibulum eleifend eu risus et viverra. Praesent mauris massa, adipiscing nec nulla sagittis, cursus imperdiet nunc. Duis eu massa vitae turpis vulputate cursus gravida a lorem.
    "
    ba_dataset.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    ba_dataset.data_dump = "http://#{PublishMyData.local_domain}/data/#{BudgetArea::DATASET_SLUG}/dump"
    ba_dataset.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    ba_dataset.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    ba_dataset.write_predicate("http://publishmydata.com/def/dataset#graph", BudgetArea.get_graph_uri)
    ba_dataset.save

  end

  desc 'replace supporting data'
  task replace_supporting_data: :environment do

    Rake::Task['db:replace_dataset_metadata'].invoke

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