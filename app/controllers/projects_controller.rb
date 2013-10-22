class ProjectsController < ApplicationController

  helper_method :remove_paging_params

  # list of projects
  def index
    @search = Search.new( params )

    respond_to do |format|

      format.html do
        Rails.logger.debug "FILTERED SEARCH"
        @projects = @search.results
        Rails.logger.debug "UNFILTERED SEARCH"
        @search_unfiltered = Search.new()
        @projects_unfiltered = @search_unfiltered.results
        @min_index = (@search.page - 1) * @search.per_page + 1
        @max_index = (@search.page - 1) * @search.per_page + @projects.length
      end

      format.atom do
        @projects = @search.results
      end

      format.csv do

        if blank_search?
          # if there are no params, redirect to pre canned version.
          redirect_to '/dumps/projects.csv'
        else
          @output_csv = Project.generate_csv(@search.results(unpaginated: true))
          render csv: @output_csv
        end
      end

      format.json do
        @projects = @search.results
        render :json => { :page => @search.page, :per_page => @search.per_page, :page_of_results => @projects, :total => @projects.total, :grant_stats => @projects.facets["offer_grant_stats"]}
      end
    end
  end

  def raw_search
    # e.g. query= '{"query": {"query_string": {"query": "*" } } }'
    respond_to do |format|
      format.json {
        render :json => Tire::Configuration.client.get("#{Tire::Configuration.url}/projects/_search", params[:query] ).body
      }
    end
  end

  protected

  def blank_search?
    non_blank_params = remove_paging_params(@search.params)
      .tap{ |h| h.delete_if { |k,v| v.blank? } } # remove blank params

    blank_search = !non_blank_params.any?
    blank_search
  end

  def remove_paging_params(hash)
    hash.tap { |h| h.delete(:page); h.delete(:per_page) }
  end

end