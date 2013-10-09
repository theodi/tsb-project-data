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

  def initialize(params)
    self.params = params # store the raw params

    # hash of field => filter
    self.facets = {
      'region_labels' => [],
      'participant_size_labels' => [],
      'status_label' => [],
      'competition_label' => [],
      'budget_area_label' => [],
      'team_label' => [],
      'participant_sic_class_labels' => []
    }
    self.terms_filters = []

    process_params()
  end

  def results
    r = Project.search page: self.page, per_page: self.per_page do |search|
      search.query do |query|
        query.boolean do |boolean|
          boolean.must { |b| b.string self.search_string }
          # boolean.must { |b| add_grant_range(b) } if self.offer_grant_from || self.offer_grant_to
          # boolean.must { |b| add_end_date_range(b) } if self.date_from
          # boolean.must { |b| add_start_date_range(b) } if self.date_to
        end
      end

      # facets
      self.facets.each_pair do |facet_field, facet_filter|
        add_facet_with_filter(search, facet_field, facet_filter)
      end

      # stats facets
      search.facet('offer_grant_stats') do |facet|
        facet.statistical 'total_offer_grant'
        self.terms_filters.each { |f| facet.facet_filter :terms, f }
        add_range_facet_filters(facet)
      end

      search.facet('offer_cost_stats') do |facet|
        facet.statistical 'total_offer_cost'
        self.terms_filters.each { |f| facet.facet_filter :terms, f }
        add_range_facet_filters(facet)
      end

      # these ones are the facet filters but without the amount filters applied
      search.facet('offer_grant_stats_unfiltered') do |facet|
        facet.statistical 'total_offer_grant'
        self.terms_filters.each { |f| facet.facet_filter :terms, f }
        add_range_facet_filters(facet, :omit_grant_range => true )
      end

      search.facet('offer_cost_stats_unfiltered') do |facet|
        facet.statistical 'total_offer_cost'
        self.terms_filters.each { |f| facet.facet_filter :terms, f }
        add_range_facet_filters(facet, :omit_grant_range => true )
      end

      # add the search filters from the facets
      self.terms_filters.each { |f| search.filter :terms, f }
      add_range_filters(search)

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

    process_facets()
    process_ranges()

  end

  def process_ranges
    process_grant_range
    process_date_range

    self.grant_range_filter = get_grant_range
    self.date_range_filter = get_date_range

  end

  def get_grant_range

    grant_range= {}
    grant_range.merge!({ gte: self.offer_grant_from }) if self.offer_grant_from
    grant_range.merge!({ lte: self.offer_grant_to }) if self.offer_grant_to

    Tire::Search::Filter.new( :range, {:total_offer_grant => grant_range }).to_hash if self.offer_grant_from || self.offer_grant_to

  end

  def get_date_range

    from_range = Tire::Search::Filter.new( :range, {:end_date => { :gte => self.date_from } } ) if self.date_from
    to_range = Tire::Search::Filter.new( :range, {:start_date => { :lte => self.date_to } } ) if self.date_to

    if from_range && to_range
      Tire::Search::Filter.new( :and, [from_range, to_range] )
    elsif from_range
      from_range
    elsif to_range
      to_range
    end

  end

  # def process_end_date_range(scope)
  #   scope.range :range, :end_date, { :gte => self.date_from }  # the project ends after the start of our range
  # end

  # def process_start_date_range(scope)
  #   scope.filter :range, start_date: { :lte => self.date_to }  # the project starts before the end of our range
  # end

  def add_range_filters(search)
    search.filter :and, get_range_filters
  end

  def add_range_facet_filters(search, opts={})
    search.facet_filter :and, get_range_filters(opts)
  end

  def get_range_filters(opts={})
    filters = []
    filters << self.grant_range_filter if (self.grant_range_filter && !opts[:omit_grant_range])
    filters << self.date_range_filter if self.date_range_filter
    filters
  end


  def add_facet_with_filter(search, field, filter_values)

    Rails.logger.debug "adding facet for #{field} with filter #{filter_values}"

    search.facet(field) do |facet|
      facet.terms field # add a term for this field

      # for all fields except this one, add facet filters for values of the other selected filters,
      # OR the current selections of this filter

      other_facet_terms = []
      self.facets.each_pair do |facet_field, values|
        unless facet_field == field
          other_facet_terms << { :terms => {facet_field => values} } if values.any?
        end
      end

      if other_facet_terms.any?
        other_facets_filter = Tire::Search::Filter.new(:and, other_facet_terms).to_hash
      end

      # Make a filter for this facet. We always want to display any selections of this facet.
      this_facet_filter = Tire::Search::Filter.new(:terms, {field => filter_values}).to_hash if filter_values.any?

      if other_facets_filter && this_facet_filter
        # if we have other facets and a selection for this facet, OR the filtes
        facet.facet_filter :or, [other_facets_filter, this_facet_filter]
      elsif other_facets_filter
        # otherwise just use the other facet terms, in an AND.
        facet.facet_filter :and, other_facet_terms
      end
    end

    # add the search filter
    self.terms_filters << { field => filter_values } if filter_values.any?

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

  def process_grant_range()
    self.offer_grant_from = self.params[:offer_grant_from].to_i unless self.params[:offer_grant_from].blank?
    self.offer_grant_to = self.params[:offer_grant_to].to_i unless self.params[:offer_grant_to].blank?
  end

  def process_date_range()
    self.date_from = DateTime.parse self.params[:date_from] unless self.params[:date_from].blank?
    self.date_to = DateTime.parse self.params[:date_to] unless self.params[:date_to].blank?
  end

  def get_pagination_params
    self.page = params[:page].to_i if params[:page].present?
    self.per_page = params[:per_page].to_i if params[:per_page].present?

    self.page ||= 1
    self.per_page ||= 10
    self.per_page = 100 if self.per_page > 100
  end

end