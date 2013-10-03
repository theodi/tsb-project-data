class Search

  attr_accessor :params

  attr_accessor :original_search_string
  attr_accessor :search_string

  attr_accessor :regions_filter
  attr_accessor :enterprise_sizes_filter

  attr_accessor :page
  attr_accessor :per_page

  def initialize(params)
    self.params = params # store the raw params
    process_params()
  end

  def results
    r = Project.search page: self.page, per_page: self.per_page do |search|
      search.query do |query|
        query.string self.search_string
      end

      # facets
      search.facet('offer_grant_stats') { statistical 'total_offer_grant' }
      search.facet('offer_cost_stats') { statistical 'total_offer_cost' }
      search.facet('regions') do |facet|
        facet.terms 'region_labels'
        facet.filter :terms, { participant_size_labels: enterprise_sizes_filter } if enterprise_sizes_filter.any?
      end
      search.facet('enterprise_sizes') { terms 'participant_size_labels' }

      # filters
      # search.filter :terms, { region_labels: regions_filter } if regions_filter.any?
      # search.filter :terms, { participant_size_labels: enterprise_sizes_filter } if  enterprise_sizes_filter.any?

      Rails.logger.debug search.to_json
    end
    Rails.logger.debug(r.inspect)
    r
  end

  private

  def process_params
    get_pagination_params
    self.original_search_string = params[:search_string]

    if self.original_search_string.blank?
      self.search_string = "*"
    else
      self.search_string = self.original_search_string
    end

    process_regions()
    process_enterprise_sizes()

  end

  def process_regions
    self.regions_filter = []
    if self.params[:regions]
      params[:regions].each_key do |region_label|
        self.regions_filter << region_label
      end
    end
  end

  def process_enterprise_sizes
    self.enterprise_sizes_filter = []
    if self.params[:enterprise_sizes]
      params[:enterprise_sizes].each_key do |e|
        self.enterprise_sizes_filter << e
      end
    end
  end

  def get_pagination_params
    self.page = params[:page].to_i if params[:page].present?
    self.per_page = params[:per_page].to_i if params[:per_page].present?

    self.page ||= 1
    self.per_page ||= 10
    self.per_page = 100 if self.per_page > 100
  end

end