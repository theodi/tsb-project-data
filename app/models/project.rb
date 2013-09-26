class Project

  include TsbResource

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