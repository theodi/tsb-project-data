namespace :db do
  ISSUE_DATE = DateTime.parse('2013-11-01')

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
    ds.issued = ISSUE_DATE
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
    cs.issued = ISSUE_DATE
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
    ont.issued = ISSUE_DATE
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
      "Technology Stategy Board Projects Data", # title,
      "Data about projects funded by the Technology Stategy Board, and the participating organizations.", #comment
      "
This dataset provides information on the projects and organizations funded by the Technology Stategy Board (and by predecessor organizations such as the Department for Trade and Industry).

Funding is provided through competitions or contracts with resulting approved projects involving one or more participants from academic and or business sectors. Payments are made up to the offered grant in arrears against agreed claims. Projects vary in size and can take from a few months to several years.

Each participant organization in each project is associated with a grant, provided by the Technology Stategy Board.  Data is provided for each grant on the amount of funding provided, as well as the total cost of the project and hence the matching contribution from the project participant.

Each organization is associated with a location, typically the address of its registered office or head office, and this is used to link funding to geographical regions.  The funding is also broken down by 'Priority Area' (for example transport, health care or energy).

The data from the Technology Stategy Board has been supplemented by openly licensed external data from a range of sources: including the [Ordnance Survey](http://data.ordnancesurvey.co.uk) (locations of postcode centroids from the Linked Data version of the CodePoint Open product) and SIC code information for companies from [Companies House](http://www.companieshouse.gov.uk/about/miscellaneous/URI.shtml) linked data.

Where possible, the data has been linked to related external web resources, including those from the [ONS](http://statistics.data.gov.uk), [Ordnance Survey](http://data.ordnancesurvey.co.uk), [Companies House](http://www.companieshouse.gov.uk/) and [OpenCorporates](http://opencorporates.com).

Update frequency: monthly

Keywords: innovation, grants, collaboration, business, academia, research, development

Time Period Covered: December 2003 to present

Geographic Coverage: England, Wales, Scotland, Northern Ireland

<div style='margin-bottom:40px; margin-top:20px;'>
  <script src='https://certificates.theodi.org/datasets/640/certificates/12714/badge.js'></script>
</div>
      ", #desc markdown
      "project_data.nt"
    )

    # regions
    replace_dataset_metadata(
      Region.get_graph_uri.to_s.gsub("/graph/", "/data/"),
      Region.get_graph_uri,
      "Regions", # title,
      "A set of ONS regions used by projects in this site.", #comment
      "Basic information on ONS regions, used to give a geographical breakdown of the data.", #desc markdown
      "regions.nt"
    )
  end

  desc 'replace ontology metadata'
  task replace_ontology_metadata: :environment do
    replace_ontology_metadata(
      TsbProjectData::ONTOLOGY_GRAPH.to_s.gsub("/graph/", "/def/"),
      TsbProjectData::ONTOLOGY_GRAPH,
      "Projects Ontology", #title
      "Terms used to describe projects funded by the Technology Strategy Board, the participating organisations and other related entities", #comment
      "This ontology documents the classes and properties used in the RDF representation of the projects data. This contains terms created specifically for the TSB Projects data.  Pre-existing external ontologies used in the data are provided separately.", #desc markdown
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
      "The set of possible products for Technology Stategy Board project competitions", #comment
      nil, #   "More information coming soon...", #desc markdown
      "regions.nt"
    )

    replace_concept_scheme_metadata(
      PriorityArea.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      PriorityArea.get_graph_uri,
      "Priority Areas", #title
      "The set of possible priority areas for Technology Stategy Board project competitions", #comment
      nil, #   "More information coming soon...", #desc markdown
      "priority_areas.nt"
    )

    replace_concept_scheme_metadata(
      EnterpriseSize.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      EnterpriseSize.get_graph_uri,
      "Enterprise Sizes", #title
      "The set of possible Enterprises sizes of organisations on Technology Stategy Board projects", #comment
     nil, #   "More information coming soon...", #desc markdown
      "regions.nt"
    )

    replace_concept_scheme_metadata(
      LegalEntityForm.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      LegalEntityForm.get_graph_uri,
      "Legal Entity Forms", #title
      "The set of possible Legal entiry forms of organisations on Technology Stategy Board projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "legal_entity_forms.nt"
    )

    replace_concept_scheme_metadata(
      ProjectStatus.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      ProjectStatus.get_graph_uri,
      "Project statuses", #title
      "The set of possible statuses for Technology Stategy Board projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "project_statuses.nt"
    )

    replace_concept_scheme_metadata(
      CostCategory.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      CostCategory.get_graph_uri,
      "Cost Categories", #title
      "The set of possible cost categories for Technology Stategy Board projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "cost_categories.nt"
    )

    replace_concept_scheme_metadata(
      SicClass.get_graph_uri.to_s.gsub("/graph/", "/def/"),
      SicClass.get_graph_uri,
      "SIC Classes",
      "The set of possible SIC classes for organisations funded by Technology Stategy Board projects", #comment
      nil, #   "More information coming soon...", #desc markdown
      "sic_codes.nt"
    )
  end

  desc 'create csv dump. This also warms up the cache'
  task create_csv_dump: :environment do
    output_csv = Project.generate_csv(Search.new().results(unpaginated: true))
    filename = "projects-#{DateTime.now.strftime('%Y%m%d')}.csv"
    File.open(File.join(TsbProjectData::DUMP_OUTPUT_PATH, filename), 'w') do |f|
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

    replace_graph(Region.get_graph_uri, 'regions.nt')
    delete_graph("http://#{PublishMyData.local_domain}/graph/priority-areas") rescue nil
    delete_graph("http://#{PublishMyData.local_domain}/graph/budget-areas") rescue nil # leave this in until old naming cleared out
    replace_graph(PriorityArea.get_graph_uri, 'priority_areas.nt')

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