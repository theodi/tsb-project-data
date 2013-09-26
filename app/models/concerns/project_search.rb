module ProjectSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

     tire.mapping do
      indexes :name, :type => 'string', :analyzer => 'snowball'
      indexes :leader_name, :type => 'string', :analyzer => 'snowball'
    end
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