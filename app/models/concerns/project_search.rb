module ProjectSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

     # http://www.elasticsearch.org/guide/reference/mapping/
     # http://www.elasticsearch.org/guide/reference/mapping/core-types
     tire.mapping do
      indexes :name, type: 'string', analyzer: 'snowball'
      indexes :leader_uri, type: 'string'
      indexes :leader_name, type: 'string', analyzer: 'snowball'
      indexes :participant_uris, type: 'string'
      indexes :participant_names, type: 'string', analyzer: 'snowball'
      indexes :offer_grant, type: 'integer'
    end
  end

  def id
    uri.to_s
  end

  def to_hash
    {
      name: label,
      leader_name: leader.label,
      leader_uri: leader.uri.to_s,
      participant_names: participants.map {|p| p.label },
      participant_uris: participants.map {|p| p.uri.to_s },
      offer_grant: supported_by.offer_grant
    }
  end

  # to clear the index
  # Project.index.delete
  #
  # examples of how to import
  # Project.index.import [ Project.first ]
  # Project.index.import Project.all.limit(10).resources.to_a
  #
  # # force a refresh
  # Project.index.refresh
  #
  # Project.search "*"
  #
  # # some useful docs re facets.
  # http://www.elasticsearch.org/guide/reference/api/search/facets/
  # http://www.elasticsearch.org/guide/reference/api/search/facets/terms-stats-facet/


end