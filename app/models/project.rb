class Project

  include TsbResource

  graph_uri TsbProjectData::DATA_GRAPH
  rdf_type Vocabulary::TSBDEF.Project

  # literals
  field :label, RDF::RDFS.label
  field :description, Vocabulary::DCTERMS.description

  # uris
  field :has_leader_uri, Vocabulary::TSBDEF.hasLeader, is_uri: true
  field :supported_by_grant_uri, Vocabulary::TSBDEF.supportedBy, is_uri: true

  def self.uri_from_slug(slug)
    "http://#{PublishMyData.local_domain}/id/#{slug}"
  end

  def dataset
    PublishMyData::Dataset.find(PublishMyData::Dataset.uri_from_data_graph_uri(self.graph_uri)) rescue nil
  end
end