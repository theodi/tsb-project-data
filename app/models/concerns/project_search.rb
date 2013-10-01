module ProjectSearch
  extend ActiveSupport::Concern

  included do
    include Tire::Model::Search

    # Some useful links.
    # http://www.elasticsearch.org/guide/reference/mapping/
    # http://www.elasticsearch.org/guide/reference/mapping/core-types
    # http://www.elasticsearch.org/guide/reference/api/search/facets/
    # http://www.elasticsearch.org/guide/reference/api/search/facets/terms-stats-facet/

    # example of building up a search
    # search = Tire::Search::Search.new('projects')
    #
    # search.query do
    #   string('*')
    #   term( :competition_call_uri, "http://tsb-projects.labs.theodi.org/id/competition-call/dd97958dedbe59f92dd2089a3140acc7")
    #   term( :label, "alloy" )
    # end
    #
    # # some facet examples
    # search.facet('competition_call_uri') { terms 'competition_call_uri', size: 5, script: " '<a href=\"' + term  + '\">' + _source.competition_call_label + '</a>'" }
    # search.facet('competition_grant_stats') { terms_stats 'competition_call_uri', 'total_offer_grant' } # stats per facet term
    # search.facet('grant_stats') { statistical 'total_offer_grant' } #stats on a field
    #
    # # next line just filters results, leaves facets. See http://www.elasticsearch.org/guide/reference/api/search/filter/
    # search.filter :term, {competition_call_uri: "http://tsb-projects.labs.theodi.org/id/competition-call/dd97958dedbe59f92dd2089a3140acc7"}
    # search.from 10 # offset
    # search.size 5  # limit
    # search.to_json # to show the request json (to debug)
    # search.results

    tire.mapping do

      # from project
      indexes :label, type: 'string', analyzer: 'snowball'
      indexes :start_date, type: 'date'
      indexes :end_date, type: 'date'
      indexes :status_uri, type: 'string'

      # from project's grants
      indexes :total_offer_grant, type: 'integer'

      # from lead org
      indexes :leader_uri, type: 'string'
      indexes :leader_label, type: 'string', analyzer: 'snowball'

      # from participants (could be many)
      indexes :participant_uris, type: 'string'
      indexes :participant_labels, type: 'string', analyzer: 'snowball'
      indexes :participant_company_numbers, type: 'string'
      indexes :participant_size_uris, type: 'string'
      indexes :participant_sic_class_uris, type: 'string'

      # from participants' sites (could be many)
      indexes :region_name, type: 'string'
      indexes :region_uri, type: 'string'
      indexes :location, type: 'geo_point'

      # competition
      indexes :competition_call_uri, type: 'string', :index  => :not_analyzed
      indexes :competition_call_label, type: 'string', analyzer: 'snowball'

      # competition's budget
      indexes :budget_area_uri, type: 'string'
      indexes :budget_area_label, type: 'string', analyzer: 'snowball'

    end
  end

  def id
    uri.to_s
  end

  def to_hash
    {
      # from project
      label: label,
      start_date: duration.start,
      start_date: duration.end,
      status_uri: project_status_uri.to_s,

      # from project's grant
      total_offer_grant: supported_by.map {|g| g.offer_grant }.inject {|sum,x| sum + x },

      # from lead org
      leader_uri: leader_uri.to_s,
      leader_label: leader.label,

      # from participants (could be many)
      participant_uris: participants.map {|p| p.uri.to_s },
      participant_labels: participants.map {|p| p.label },
      participant_company_numbers: participants.map {|p| p.company_number },
      participant_size_uris: participants.map {|p| p.enterprise_size_uri },
      participant_sic_class_uris: participants.map {|p| p.sic_class_uri },

      # from participants' sites (could be many)
      region_names: participants.map {|p| p.site.region.label rescue nil },
      region_uris: participants.map {|p| p.site.region.uri.to_s rescue nil },
      locations: participants.map{ |p| "#{p.lat},#{p.long}" rescue nil },

      # competition
      competition_call_uri: (competition_call_uri.to_s rescue nil),
      competition_call_label: (competition_call.label rescue nil),

      #competition's team
      team_uri: (competition_call.team_uri.to_s rescue nil),
      team_label: (competition_call.team.label rescue nil),

      # competition's budget
      budget_area_uri: (competition_call.budget_area_uri.to_s rescue nil),
      budget_area_label: (competition_call.budget_area.label rescue nil),
    }
  end
end