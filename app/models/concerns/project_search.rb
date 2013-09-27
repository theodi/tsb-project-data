module ProjectSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

     # http://www.elasticsearch.org/guide/reference/mapping/
     # http://www.elasticsearch.org/guide/reference/mapping/core-types
     tire.mapping do

      # from project
      indexes :name, type: 'string', analyzer: 'snowball'
      indexes :start_date, type: 'date'
      indexes :end_date, type: 'date'

      # from project's grant
      indexes :offer_grant, type: 'integer'

      # lead org
      indexes :leader_uri, type: 'string'
      indexes :leader_name, type: 'string', analyzer: 'snowball'

      # from participants (could be many)
      indexes :participant_uri, type: 'string'
      indexes :participant_name, type: 'string', analyzer: 'snowball'

      indexes :participant_company_number, type: 'string'

      indexes :region_name, type: 'string'
      indexes :region_uri, type: 'string'
      indexes :location, type: 'geopoint'


      # TODO:
      # enterprise size

      #???
      # project SIC class
      # participant SIC class
      # Competition
      # TSB Area

    end
  end

  def id
    uri.to_s
  end

  def to_hash
    {
      name: label,

      start_date: start_date,
      start_date: end_date,

      offer_grant: supported_by.offer_grant,

      leader_uri: leader.uri.to_s,
      leader_name: leader.label,

      participant_names: participants.map {|p| p.label },
      participant_uris: participants.map {|p| p.uri.to_s },
      participant_company_numbers: participants.map {|p| p.company_number },

      region_names: participants.map {|p| p.site.region.label rescue nil },
      region_uris: participants.map {|p| p.site.region.uri.to_s rescue nil },
      locations: participants.map{ |p| "#{p.lat},#{p.long}" rescue nil }
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