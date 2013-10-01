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
      indexes :status_uri, type: 'string', :index  => :not_analyzed

      # from project's grants
      indexes :total_offer_grant, type: 'integer'

      # from lead org
      indexes :leader_uri, type: 'string', :index  => :not_analyzed
      indexes :leader_label, type: 'string', analyzer: 'snowball'

      # from participants (could be many)
      indexes :participant_uris, type: 'string', :index  => :not_analyzed
      indexes :participant_labels, type: 'string', analyzer: 'snowball'
      indexes :participant_company_numbers, type: 'string', :index  => :not_analyzed
      indexes :participant_size_uris, type: 'string', :index  => :not_analyzed
      indexes :participant_sic_class_uris, type: 'string', :index  => :not_analyzed

      # from participants' sites (could be many)
      indexes :region_name, type: 'string'
      indexes :region_uri, type: 'string', :index  => :not_analyzed
      indexes :location, type: 'geo_point'

      # competition
      indexes :competition_call_uri, type: 'string', :index  => :not_analyzed
      indexes :competition_call_label, type: 'string', analyzer: 'snowball'

      # competition's budget
      indexes :budget_area_uri, type: 'string', :index  => :not_analyzed
      indexes :budget_area_label, type: 'string', analyzer: 'snowball'

    end
  end

  def id
    uri.to_s
  end

  # generates an index document, from an in-memory hash of all resources
  def index_doc(resources_hash)
    @duration_object = resources_hash[self.duration_uri]
    @grant_objects = self.supported_by_uris.map {|grant_uri| resources_hash[grant_uri] }
    @lead_org_object = resources_hash[self.leader_uri]
    @participant_objects = self.participants_uris.map {|org_uri| resources_hash[org_uri] }
    @site_objects = @participant_objects.map {|p| resources_hash[p.site_uri] }
    @region_objects = @site_objects.map {|s| resources_hash[s.region_uri] }

    doc = to_hash({_id: self.uri.to_s, type: 'project'})
  end

  def to_hash(doc={})
    doc
      .merge(project_index_fields)
      .merge(duration_index_fields)
      .merge(lead_org_index_fields)
      .merge(grant_index_fields)
      .merge(participant_index_fields)
      .merge(region_index_fields)
      .merge(competition_index_fields)
      .merge(team_index_fields)
      .merge(budget_area_index_fields)

    # {
    #   # from project
    #   label: label,
    #   status_uri: project_status_uri.to_s,

    #   # from duration
    #   start_date: duration.start,
    #   start_date: duration.end,

    #   # from project's grant
    #   total_offer_grant: supported_by.map {|g| g.offer_grant }.inject {|sum,x| sum + x },

    #   # from lead org
    #   leader_uri: leader_uri.to_s,
    #   leader_label: leader.label,

    #   # from participants (could be many)
    #   participant_uris: participants.map {|p| p.uri.to_s },
    #   participant_labels: participants.map {|p| p.label },
    #   participant_company_numbers: participants.map {|p| p.company_number },
    #   participant_size_uris: participants.map {|p| p.enterprise_size_uri },
    #   participant_sic_class_uris: participants.map {|p| p.sic_class_uri },

    #   # from participants' sites (could be many)
    #   region_names: participants.map {|p| p.site.region.label rescue nil },
    #   region_uris: participants.map {|p| p.site.region.uri.to_s rescue nil },
    #   locations: participants.map{ |p| "#{p.lat},#{p.long}" rescue nil },

    #   # competition
    #   competition_call_uri: (competition_call_uri.to_s rescue nil),
    #   competition_call_label: (competition_call.label rescue nil),

    #   #competition's team
    #   team_uri: (competition_call.team_uri.to_s rescue nil),
    #   team_label: (competition_call.team.label rescue nil),

    #   # competition's budget
    #   budget_area_uri: (competition_call.budget_area_uri.to_s rescue nil),
    #   budget_area_label: (competition_call.budget_area.label rescue nil),
    # }
  end

  private

  def project_index_fields
    {
      label: label,
      status_uri: project_status_uri.to_s
    }
  end

  def duration_index_fields
    @duration_object ||= self.duration
    {
      start_date: @duration_object.start,
      start_date: @duration_object.end
    }
  end

  def lead_org_index_fields
    @lead_org_object ||= self.leader
    {
       leader_uri: @lead_org_object.uri.to_s,
       leader_label: @lead_org_object.label
    }
  end

  def grant_index_fields
    @grant_objects ||= self.supported_by
    {
       total_offer_grant: @grant_objects.map {|g| g.offer_grant }.inject {|sum,x| sum + x }
    }
  end

  def participant_index_fields
    @participant_objects ||= self.participants
    {
      participant_uris: @participant_objects.map { |p| p.uri.to_s },
      participant_labels: @participant_objects.map { |p| p.label },
      participant_company_numbers: @participant_objects.map { |p| p.company_number },
      participant_size_uris: @participant_objects.map { |p| p.enterprise_size_uri.to_s },
      participant_sic_class_uris: @participant_objects.map {|p| p.sic_class_uri.to_s },
      locations: @participant_objects.map{ |p| "#{p.lat},#{p.long}" rescue nil }
    }
  end

  def region_index_fields
    @region_objects ||= self.participants.map {|p| p.site.region }
    {
      region_names: @region_objects.map {|r| r.label rescue nil },
      region_uris: @region_objects.map {|r| r.uri.to_s rescue nil }
    }
  end

  def competition_index_fields
    @competition_object ||= self.competition_call
    {
      competition_call_uri: (@competition_object.uri.to_s rescue nil),
      competition_call_label: (@competition_object.label rescue nil)
    }
  end

  def team_index_fields
    @team_object ||= self.competition_call.team
    {
      team_uri: (@team_object.uri.to_s rescue nil),
      team_label: (@team_object.label rescue nil)
    }
  end

  def budget_area_index_fields
    @budget_area_object ||= self.competition_call.budget_area
    {
      budget_area_uri: (@budget_area_object.uri.to_s rescue nil),
      budget_area_label: (@budget_area_object.label rescue nil)
    }
  end



end