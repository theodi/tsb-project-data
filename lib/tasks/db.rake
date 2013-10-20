namespace :db do

  def delete_graph(graph_uri)
    url = "#{TsbProjectData::DATA_ENDPOINT}?graph=#{graph_uri}"
    RestClient::Request.execute(
      :method => :delete,
      :url => url,
      :timeout => 300
    )
  end

  def replace_graph(graph_uri, filename, content_type='text/plain')

    puts "loading #{filename} -> #{graph_uri}"
    url = "#{TsbProjectData::DATA_ENDPOINT}?graph=#{graph_uri}"

    RestClient::Request.execute(
      :method => :put,
      :url => url,
      :payload => File.read(File.join(Rails.root, 'public', 'dumps', filename)),
      :headers => {content_type: content_type},
      :timeout => 300
    )
  end

  def replace_dataset_metadata(uri, data_graph, title, comment, description_markdown, dump_filename)

    delete_graph("#{data_graph.to_s}/metadata") rescue puts "*** no metadata graph for #{data_graph.to_s} ***"

    ds = PublishMyData::Dataset.new(
      uri,
      "#{data_graph.to_s}/metadata"
    )

    ds.title = title
    ds.label = ds.title
    ds.comment = comment
    ds.description = description_markdown
    ds.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    ds.data_dump = "http://#{PublishMyData.local_domain}/dumps/#{dump_filename}"
    ds.data_graph_uri = data_graph
    ds.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    ds.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    ds.save!
  end


  def replace_concept_scheme_metadata(uri, data_graph, title, comment, description_markdown, dump_filename)
    delete_graph("#{data_graph.to_s}/metadata") rescue puts "*** no metadata graph for #{data_graph.to_s} ***"

    cs = PublishMyData::ConceptScheme.new(
      uri,
      "#{data_graph.to_s}/metadata"
    )

    cs.title = title
    cs.label = cs.title
    cs.comment = comment
    cs.description = description_markdown
    cs.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    cs.data_dump = "http://#{PublishMyData.local_domain}/dumps/#{dump_filename}"
    cs.data_graph_uri = data_graph
    cs.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    cs.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    cs.save!
  end

  def replace_ontology_metadata(uri, data_graph, title, comment, description_markdown, dump_filename)

    delete_graph("#{data_graph.to_s}/metadata") rescue puts "*** no metadata graph for #{data_graph.to_s} ***"

    ont = PublishMyData::Ontology.new(
      uri,
      "#{data_graph.to_s}/metadata"
    )

    ont.title = title
    ont.label = ont.title
    ont.comment = comment
    ont.description = description_markdown
    ont.contact_email = "mailto:hello@swirrl.com"
    #dataset.license = "TBC"
    #dataset.publisher = "TBC"

    ont.data_dump = "http://#{PublishMyData.local_domain}/dumps/#{dump_filename}"
    ont.data_graph_uri = data_graph
    ont.write_predicate(Vocabulary::DCTERMS.references, "http://#{PublishMyData.local_domain}/docs")
    ont.write_predicate("http://rdfs.org/ns/void#sparqlEndpoint", "http://#{PublishMyData.local_domain}/sparql")
    ont.save!
  end

  def replace_third_party_ontology_metadata(uri, label, data_graph, dump_filename)
    delete_graph("#{data_graph.to_s}/metadata") rescue puts "*** no metadata graph for #{data_graph.to_s} ***"

    puts "creating third party metadata for #{uri}"

    # use generic resource to avoid problems with saving the publisher (where it's not a uri)
    o = PublishMyData::ThirdParty::Ontology.new(
      uri,
      "#{data_graph.to_s}/metadata"
    )

    puts "GRAPH: #{data_graph.to_s}/metadata"

    o.label = label
    o.data_dump = "http://#{PublishMyData.local_domain}/dumps/#{dump_filename}"
    o.data_graph_uri = data_graph

    o.save! rescue puts o.errors.inspect
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

    # main dataset
    replace_dataset_metadata(
      "http://#{PublishMyData.local_domain}/data/#{TsbProjectData::DATASET_SLUG}",
      TsbProjectData::DATA_GRAPH,
      "TSB Projects Data", # title,
      "comment", #comment
      "description", #desc markdown
      "project_data.nt"
    )

    # regions
    replace_dataset_metadata(
      Region.get_graph_uri.to_s.gsub("/graph/", "/data/"),
      Region.get_graph_uri,
      "TSB Regions", # title,
      "comment", #comment
      "description", #desc markdown
      "regions.nt"
    )

    # budget areas
    replace_dataset_metadata(
      BudgetArea.get_graph_uri.to_s.gsub("/graph/", "/data/"),
      BudgetArea.get_graph_uri,
      "TSB Budget Areas", # title,
      "comment", #comment
      "description", #desc markdown
      "budget_areas.nt"
    )

  end

  desc 'replace ontology metadata'
  task replace_ontology_metadata: :environment do
    replace_ontology_metadata(
      TsbProjectData::ONTOLOGY_GRAPH.to_s.gsub("/graph/", "/def/"),
      TsbProjectData::ONTOLOGY_GRAPH,
      "TSB Projects Ontology", #title
      "comment", #comment
      "description", #desc markdown
      "ontology.nt"
    )

    replace_third_party_ontology_metadata(
      "http://data.ordnancesurvey.co.uk/ontology/admingeo/",
      "Administrative Geography",
      TsbProjectData::ADMINGEO_ONTOLOGY_GRAPH,
      'third_party/admingeo.ttl'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/2006/vcard/ns",
      "An Ontology For vcards",
      TsbProjectData::VCARD_ONTOLOGY_GRAPH,
      'third_party/vcard.ttl'
    )

    # replace_third_party_ontology_metadata(
    #   "http://purl.org/dc/terms/",
    #   "Dublin Core Terms",
    #   TsbProjectData::DCTERMS_ONTOLOGY_GRAPH,
    #   'third_party/dcterms.rdf'
    # )

    replace_third_party_ontology_metadata(
      "http://xmlns.com/foaf/0.1/",
      "Friend of a Friend (FOAF)",
      TsbProjectData::FOAF_ONTOLOGY_GRAPH,
      'third_party/foaf.rdf'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/2003/01/geo/wgs84_pos#",
      "WGS84 Geo Positioning",
      TsbProjectData::GEO_ONTOLOGY_GRAPH,
      'third_party/wgs84_pos.rdf'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/2002/07/owl",
      "The OWL 2 Schema vocabulary (OWL 2)",
      TsbProjectData::OWL_ONTOLOGY_GRAPH,
      'third_party/owl.rdf'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/ns/org#",
      "Core Organization Ontology",
      TsbProjectData::ORG_ONTOLOGY_GRAPH,
      'third_party/org.ttl'
    )

    replace_third_party_ontology_metadata(
      "http://data.ordnancesurvey.co.uk/ontology/postcode/",
      "Postcode Ontology",
      TsbProjectData::POSTCODE_ONTOLOGY_GRAPH,
      'third_party/postcode.owl'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/2004/02/skos/core",
      "SKOS Vocabulary",
      TsbProjectData::SKOS_ONTOLOGY_GRAPH,
      'third_party/skos.rdf'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/2000/01/rdf-schema#",
      "The RDF Schema vocabulary (RDFS)",
      TsbProjectData::RDFS_ONTOLOGY_GRAPH,
      'third_party/rdfs.rdf'
    )

    replace_third_party_ontology_metadata(
      "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      "The RDF Vocabulary (RDF)",
      TsbProjectData::RDF_ONTOLOGY_GRAPH,
      'third_party/rdf.rdf'
    )

    replace_third_party_ontology_metadata(
      "http://purl.org/NET/c4dm/timeline.owl",
      "The Timeline ontology",
      TsbProjectData::TIMELINE_ONTOLOGY_GRAPH,
      'third_party/timeline.ttl'
    )

  end

  task replace_concept_scheme_metadata: :environment do
    replace_concept_scheme_metadata(
      Product.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      Product.get_graph_uri,
      "Products", #title
      "comment", #comment
      "description", #desc markdown
      "regions.nt"
    )

    replace_concept_scheme_metadata(
      EnterpriseSize.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      EnterpriseSize.get_graph_uri,
      "Enterprise Sizes", #title
      "comment", #comment
      "description", #desc markdown
      "regions.nt"
    )

    replace_concept_scheme_metadata(
      LegalEntityForm.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      LegalEntityForm.get_graph_uri,
      "Legal Entity Forms", #title
      "comment", #comment
      "description", #desc markdown
      "legal_entity_forms.nt"
    )

    replace_concept_scheme_metadata(
      ProjectStatus.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      ProjectStatus.get_graph_uri,
      "Project statuses", #title
      "comment", #comment
      "description", #desc markdown
      "project_statuses.nt"
    )

    replace_concept_scheme_metadata(
      CostCategory.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      CostCategory.get_graph_uri,
      "Cost Categories", #title
      "comment", #comment
      "description", #desc markdown
      "cost_categories.nt"
    )

    replace_concept_scheme_metadata(
      SicClass.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      SicClass.get_graph_uri,
      "SIC Classes", #title
      "comment", #comment
      "description", #desc markdown
      "sic_codes.nt"
    )
  end


  desc 'replace supporting data'
  task replace_supporting_data: :environment do

    Rake::Task['db:replace_dataset_metadata'].invoke
    Rake::Task['db:replace_ontology_metadata'].invoke
    Rake::Task['db:replace_concept_scheme_metadata'].invoke

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
    replace_graph(TsbProjectData::ORG_ONTOLOGY_GRAPH, 'third_party/org.ttl', 'text/turtle')
    replace_graph(TsbProjectData::DCTERMS_ONTOLOGY_GRAPH,'third_party/dcterms.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::VCARD_ONTOLOGY_GRAPH,'third_party/vcard.ttl', 'text/turtle')
    replace_graph(TsbProjectData::FOAF_ONTOLOGY_GRAPH,'third_party/foaf.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::POSTCODE_ONTOLOGY_GRAPH,'third_party/postcode.owl', 'application/rdf+xml')
    replace_graph(TsbProjectData::GEO_ONTOLOGY_GRAPH,'third_party/wgs84_pos.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::ADMINGEO_ONTOLOGY_GRAPH,'third_party/admingeo.ttl', 'text/turtle')
    replace_graph(TsbProjectData::RDF_ONTOLOGY_GRAPH,'third_party/rdf.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::RDFS_ONTOLOGY_GRAPH,'third_party/rdfs.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::OWL_ONTOLOGY_GRAPH,'third_party/owl.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::SKOS_ONTOLOGY_GRAPH,'third_party/skos.rdf', 'application/rdf+xml')
    replace_graph(TsbProjectData::TIMELINE_ONTOLOGY_GRAPH,'third_party/timeline.ttl', 'text/turtle')

  end

  desc 'replace project dataset data.'
  task replace_project_data: :environment do
    replace_graph(TsbProjectData::DATA_GRAPH, 'project_data.nt')
  end

end