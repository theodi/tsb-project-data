namespace :db do

  def delete_graph(graph_uri)
    url = "#{TsbProjectData::DATA_ENDPOINT}?graph=#{graph_uri}"
    RestClient::Request.execute(
      :method => :delete,
      :url => url,
      :timeout => 300
    )
  end

  def replace_graph(graph_uri, filename, third_party=false, content_type='text/plain')

    if third_party
      path = File.join(Rails.root, 'public', 'dumps', 'third_party', filename)
    else
      path = File.join(TsbProjectData::DUMP_OUTPUT_PATH, filename)
    end


    puts "loading #{filename} -> #{graph_uri}"
    url = "#{TsbProjectData::DATA_ENDPOINT}?graph=#{graph_uri}"

    RestClient::Request.execute(
      :method => :put,
      :url => url,
      :payload => File.read(path),
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
    ds.contact_email = "mailto:lee.mullin@tsb.gov.uk"
    ds.license = "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/"
    ds.publisher = "http://innovateuk.org"

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
    cs.contact_email = "mailto:lee.mullin@tsb.gov.uk"
    cs.license = "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/"
    cs.publisher = "http://innovateuk.org"

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
    ont.contact_email = "mailto:lee.mullin@tsb.gov.uk"
    ont.license = "http://www.nationalarchives.gov.uk/doc/open-government-licence/version/2/"
    ont.publisher = "http://innovateuk.org"

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
      "Data about projects funded by the TSB, and the participating organisations.", #comment
      "More information coming soon...", #desc markdown
      "project_data.nt"
    )

    # regions
    replace_dataset_metadata(
      Region.get_graph_uri.to_s.gsub("/graph/", "/data/"),
      Region.get_graph_uri,
      "TSB Regions", # title,
      "A set of ONS regions used by projects in this site.", #comment
      "More information coming soon...", #desc markdown
      "regions.nt"
    )
  end

  desc 'replace ontology metadata'
  task replace_ontology_metadata: :environment do
    replace_ontology_metadata(
      TsbProjectData::ONTOLOGY_GRAPH.to_s.gsub("/graph/", "/def/"),
      TsbProjectData::ONTOLOGY_GRAPH,
      "TSB Projects Ontology", #title
      "Terms used to describe projects funded by the TSB, the participating organisations and other related entities", #comment
      "More information coming soon...", #desc markdown
      "ontology.nt"
    )

    # make sure all the third party ones are deleted.
    delete_graph("#{TsbProjectData::ADMINGEO_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::VCARD_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::DCTERMS_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::FOAF_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::GEO_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::OWL_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::ORG_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::POSTCODE_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::SKOS_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::RDFS_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::RDF_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::TIMELINE_ONTOLOGY_GRAPH.to_s}/metadata") rescue nil
    delete_graph("#{TsbProjectData::STATSGEO_GRAPH.to_s}/metadata") rescue nil

  end

  task replace_concept_scheme_metadata: :environment do
    replace_concept_scheme_metadata(
      Product.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      Product.get_graph_uri,
      "Products", #title
      "The set of possible products for TSB project competitions", #comment
      nil, #   "More information coming soon...", #desc markdown
      "regions.nt"
    )

    replace_concept_scheme_metadata(
      BudgetArea.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      BudgetArea.get_graph_uri,
      "Budget Areas", #title
      "The set of possible budget areas for TSB project competitions", #comment
      nil, #   "More information coming soon...", #desc markdown
      "budget_areas.nt"
    )

    replace_concept_scheme_metadata(
      EnterpriseSize.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      EnterpriseSize.get_graph_uri,
      "Enterprise Sizes", #title
      "The set of possible Enterprises sizes of organisations on TSB projects", #comment
     nil, #   "More information coming soon...", #desc markdown
      "regions.nt"
    )

    replace_concept_scheme_metadata(
      LegalEntityForm.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      LegalEntityForm.get_graph_uri,
      "Legal Entity Forms", #title
      "The set of possible Legal entiry forms of organisations on TSB projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "legal_entity_forms.nt"
    )

    replace_concept_scheme_metadata(
      ProjectStatus.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      ProjectStatus.get_graph_uri,
      "Project statuses", #title
      "The set of possible statuses for TSB projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "project_statuses.nt"
    )

    replace_concept_scheme_metadata(
      CostCategory.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      CostCategory.get_graph_uri,
      "Cost Categories", #title
      "The set of possible cost categories for TSB projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "cost_categories.nt"
    )

    replace_concept_scheme_metadata(
      SicClass.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      SicClass.get_graph_uri,
      "SIC Classes",
      "The set of possible SIC classes for organisations funded by TSB projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "sic_codes.nt"
    )
  end

  desc 'create csv dump. This also warms up the cache'
  task create_csv_dump: :environment do
    output_csv = Project.generate_csv(Search.new().results(unpaginated: true))
    File.open(File.join(TsbProjectData::DUMP_OUTPUT_PATH, 'projects.csv'), 'w') do |f|
      f.write(output_csv)
    end
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
    delete_graph("http://#{PublishMyData.local_domain}/graph/budget-areas") rescue nil
    replace_graph(BudgetArea.get_graph_uri, 'budget_areas.nt')

    # TODO: add some ontology metadata
    replace_graph(TsbProjectData::ONTOLOGY_GRAPH, 'ontology.nt')

    # load external ontologies
    replace_graph(TsbProjectData::ORG_ONTOLOGY_GRAPH, 'org.ttl', true, 'text/turtle')
    replace_graph(TsbProjectData::DCTERMS_ONTOLOGY_GRAPH,'dcterms.rdf',true, 'application/rdf+xml')
    replace_graph(TsbProjectData::VCARD_ONTOLOGY_GRAPH,'vcard.ttl', true,  'text/turtle')
    replace_graph(TsbProjectData::FOAF_ONTOLOGY_GRAPH,'foaf.rdf', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::POSTCODE_ONTOLOGY_GRAPH,'postcode.owl', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::GEO_ONTOLOGY_GRAPH,'wgs84_pos.rdf', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::ADMINGEO_ONTOLOGY_GRAPH, 'admingeo.ttl', true, 'text/turtle')
    replace_graph(TsbProjectData::RDF_ONTOLOGY_GRAPH,'rdf.rdf', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::RDFS_ONTOLOGY_GRAPH,'rdfs.rdf', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::OWL_ONTOLOGY_GRAPH,'owl.rdf', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::SKOS_ONTOLOGY_GRAPH,'skos.rdf', true, 'application/rdf+xml')
    replace_graph(TsbProjectData::TIMELINE_ONTOLOGY_GRAPH, 'timeline.ttl', true, 'text/turtle')
    replace_graph(TsbProjectData::STATSGEO_GRAPH, 'statistical-geography.ttl', true, 'text/turtle')

  end

  desc 'replace project dataset data.'
  task replace_project_data: :environment do
    replace_graph(TsbProjectData::DATA_GRAPH, 'project_data.nt')
  end

end