class Search

  attr_accessor :params

  attr_accessor :original_search_string
  attr_accessor :search_string

  attr_accessor :facets # hash of field => filter

  attr_accessor :page
  attr_accessor :per_page

  def initialize(params)
    self.params = params # store the raw params

    # hash of field => filter
    self.facets = {
      'region_labels' => [],
      'participant_size_labels' => [],
      'status_label' => []
    }

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

      self.facets.each_pair do |facet_field, facet_filter|
        add_facet_with_filter(search, facet_field, facet_filter)
      end

      Rails.logger.debug search.to_json
    end
    Rails.logger.debug(r.inspect)
    r
  end

  private

  def add_facet_with_filter(search, field, filter_values)

    Rails.logger.debug "adding facet for #{field} with filter #{filter_values}"

    search.facet(field) do |facet|
      facet.terms field # add a term for this field

      # for all fields except this one, add facet filters
      # for values of the other selected filters, plus the current selection of this filter

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
    search.filter :terms, { field => filter_values } if filter_values.any?
  end

  def process_params
    get_pagination_params
    self.original_search_string = params[:search_string]

    if self.original_search_string.blank?
      self.search_string = "*"
    else
      self.search_string = self.original_search_string
    end

    process_facets()
  end

  def process_facets
    self.facets.each_key do |facet_name|
      process_facet(facet_name)
    end
  end

  def process_facet(facet_name)
    Rails.logger.debug "processing #{facet_name}"

    if self.params[facet_name]
      params[facet_name].each_key do |val|
        self.facets[facet_name] << val
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