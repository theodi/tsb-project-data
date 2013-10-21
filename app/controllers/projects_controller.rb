class ProjectsController < ApplicationController

  # list of projects
  def index
    @search = Search.new( params )

    respond_to do |format|

      format.html do
        @projects = @search.results
        @search_unfiltered = Search.new()
        @projects_unfiltered = @search_unfiltered.results
        @min_index = (@search.page - 1) * @search.per_page + 1
        @max_index = (@search.page - 1) * @search.per_page + @search.results.length
      end

      format.atom do
        @projects = @search.results
      end

      format.csv do
        @output_csv = Project.generate_csv(@search.results(unpaginated: true))
        render csv: @output_csv
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

end