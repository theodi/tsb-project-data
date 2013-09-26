module TsbResource
  extend ActiveSupport::Concern

  included do
    include Tripod::Resource
    include PublishMyData::BasicFeatures
  end

  def dataset
    PublishMyData::Dataset.find(PublishMyData::Dataset.uri_from_data_graph_uri(self.graph_uri)) rescue nil
  end

  def self.uri_from_slug(slug)
    "http://#{PublishMyData.local_domain}/id/#{slug}"
  end

end