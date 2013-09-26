class Project

  include TsbResource

  include Tire::Model::Search

  tire.mapping do
    indexes :name, :type => 'string', :analyzer => 'snowball'
    indexes :leader_name, :type => 'string', :analyzer => 'snowball'
  end

  def id
    uri.to_s
  end

  def to_hash
    {
      :name => label,
      :leader_name => leader.label
    }
  end

  # to bulk load:
  # Project.index.delete
  #
  # Project.index.import [ Project.first ]
  # Project.index.import Project.all.limit(10).resources.to_a
  #
  # Project.index.refresh
  #
  # http://www.elasticsearch.org/guide/reference/api/search/facets/
  # http://www.elasticsearch.org/guide/reference/api/search/facets/terms-stats-facet/

  graph_uri TsbProjectData::DATA_GRAPH
  rdf_type Vocabulary::TSBDEF.Project

  # literals
  field :label, RDF::RDFS.label
  field :description, Vocabulary::DCTERMS.description

  # links
  linked_to :leader, Vocabulary::TSBDEF.hasLeader, class_name: 'Organization'
  linked_to :supported_by, Vocabulary::TSBDEF.supportedBy, class_name: 'Grant'

  def self.uri_from_slug(slug)
    "http://#{PublishMyData.local_domain}/id/#{slug}"
  end

  def dataset
    PublishMyData::Dataset.find(PublishMyData::Dataset.uri_from_data_graph_uri(self.graph_uri)) rescue nil
  end

end