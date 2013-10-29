class Search

  attr_accessor :params

  attr_accessor :original_search_string
  attr_accessor :search_string

  attr_accessor :facets # hash of field => filter

  attr_accessor :offer_grant_from
  attr_accessor :offer_grant_to

  attr_accessor :date_from
  attr_accessor :date_to

  attr_accessor :page
  attr_accessor :per_page

  attr_accessor :terms_filters # terms filters

  attr_accessor :grant_range_filter # range filters
  attr_accessor :date_range_filter # just the date range filters

  attr_accessor :sort_by
  attr_accessor :sort_order

  attr_accessor :sort_fields

  def initialize(params={})
    self.params = params.tap { |h| h.delete(:controller); h.delete(:action); h.delete(:format); h.delete(:utf8); h.delete(:commit) } # store the raw params minus rails's params

    # hash of field => filter
    self.facets = {
      'region_labels' => [],
      'participant_size_labels' => [],
      'status_label' => [],
      'budget_area_label' => [],
      'participant_sic_section_labels' => [],
      'product_label' => [],
      'participant_legal_entity_form_labels' => []
    }

    self.sort_fields = {
      'project name' => 'label_unanalyzed_downcase',
      'grant amount' => 'total_offer_grant',
      'start date' => 'start_date',
      'relevance' => '_score'
    }

    self.terms_filters = []

    process_params()
  end

  def results(opts={})

    if opts[:unpaginated]
      results_page = 1
      results_per_page = 10000
    else
      results_page = self.page
      results_per_page = self.per_page
    end

    r = Project.search page: results_page, per_page: results_per_page do |search|

      search.query do |query|
        query.string Tire::Utils.escape(self.search_string)
      end

      search.sort do |sort|
        sort.by self.sort_by, self.sort_order
      end

      # facets
      self.facets.each_pair do |facet_field, filter_values|
        add_facet_with_filter(search, facet_field)
        self.terms_filters << { facet_field => filter_values } if filter_values.any? # store the terms filters for later
      end

      # stats facets
      search.facet('offer_grant_stats') do |facet|
        facet.statistical 'total_offer_grant'
        add_facet_filter('offer_grant_stats', facet)
      end

      search.facet('offer_cost_stats') do |facet|
        facet.statistical 'total_offer_cost'
        add_facet_filter('offer_grant_stats', facet)
      end

      search.facet('offer_grant_stats_unfiltered') do |facet|
        facet.statistical 'total_offer_grant'
      end

      search.facet('start_date_stats_unfiltered') do |facet|
        facet.statistical 'start_date'
      end

      search.facet('end_date_stats_unfiltered') do |facet|
        facet.statistical 'end_date'
      end

      # add the terms filters to the search
      self.terms_filters.each { |f| search.filter :terms, f }

      # finally, add the range filters.
      search.filter :and, get_range_filters if get_range_filters.any?

      Rails.logger.debug search.to_json
    end
    r
  end

  private

  def process_params
    process_sorting_params()
    process_pagination_params()
    process_search_string()
    process_facets()
    process_ranges()
  end

  def process_search_string
    self.original_search_string = params[:search_string]

    if self.original_search_string.blank?
      self.search_string = "*"
    else
      self.search_string = self.original_search_string
    end
  end

  def process_ranges
    process_grant_range()
    process_date_range()
  end

  def get_range_filters(opts={})
    filters = []
    filters << self.grant_range_filter if self.grant_range_filter
    filters << self.date_range_filter if self.date_range_filter
    filters
  end

  def get_filter_for_other_facets(field)
    other_facet_terms = []
    self.facets.each_pair do |facet_field, values|
      other_facet_terms << { :terms => {facet_field => values} } if (facet_field != field && values.any?)
    end
    other_facet_terms

    Tire::Search::Filter.new(:and, other_facet_terms).to_hash if other_facet_terms.any?
  end

  def get_facet_filters(field)
    other_facets_filter = get_filter_for_other_facets(field)

    # AND-ed range filtres
    range_filters = Tire::Search::Filter.new(:and, get_range_filters).to_hash if get_range_filters.any?

    facet_filters = []
    facet_filters << other_facets_filter if other_facets_filter
    facet_filters << range_filters if range_filters

    facet_filters
  end

  # add a facet filter for our field.
  # this will filter this facet by all the other facets.
  def add_facet_filter(field, facet)
    facet_filters = get_facet_filters(field)
    facet.facet_filter :and, facet_filters if facet_filters.any?
  end

  def add_facet_with_filter(search, field)
    search.facet(field) do |facet|
      facet.terms(field, size: 100)
       # add a facet term for this field
      add_facet_filter(field, facet) # add a facet filter
    end
  end

  def process_facets
    self.facets.each_key do |facet_name|
      process_facet(facet_name)
    end
  end

  def process_facet(facet_name)
    if self.params[facet_name]
      params[facet_name].each_key do |val|
        self.facets[facet_name] << val
      end
    end
  end

  def process_grant_range
    self.offer_grant_from = self.params[:offer_grant_from].to_i unless self.params[:offer_grant_from].blank?
    self.offer_grant_to = self.params[:offer_grant_to].to_i unless self.params[:offer_grant_to].blank?

    grant_range= {}
    grant_range.merge!({ gte: self.offer_grant_from }) if self.offer_grant_from
    grant_range.merge!({ lte: self.offer_grant_to }) if self.offer_grant_to

    if self.offer_grant_from || self.offer_grant_to
      self.grant_range_filter = Tire::Search::Filter.new( :range, {:total_offer_grant => grant_range }).to_hash
    end
  end

  def process_date_range
    self.date_from = DateTime.parse self.params[:date_from] unless self.params[:date_from].blank?
    self.date_to = DateTime.parse self.params[:date_to] unless self.params[:date_to].blank?

    from_range = Tire::Search::Filter.new( :range, {:end_date => { :gte => self.date_from } } ) if self.date_from
    to_range = Tire::Search::Filter.new( :range, {:start_date => { :lte => self.date_to } } ) if self.date_to

    if from_range && to_range
      range_filter = Tire::Search::Filter.new( :and, [from_range.to_hash, to_range.to_hash] )
    elsif from_range
      range_filter = from_range
    elsif to_range
      range_filter = to_range
    end

    self.date_range_filter = range_filter.to_hash if range_filter
  end

  def process_sorting_params

    self.sort_by = params[:sort_by]
    self.sort_order = params[:sort_order]

    self.sort_by = '_score' unless self.sort_fields.values.include?(self.sort_by)
    self.sort_order = 'desc' unless ['asc', 'desc'].include?(self.sort_order)
  end

  def process_pagination_params
    self.page = params[:page].to_i if params[:page].present?
    self.per_page = params[:per_page].to_i if params[:per_page].present?

    self.page ||= 1
    self.per_page ||= 10
    self.per_page = 100 if self.per_page > 100
  end

end