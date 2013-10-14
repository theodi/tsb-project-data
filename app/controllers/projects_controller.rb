class ProjectsController < ApplicationController

  # list of projects
  def index
    @search = Search.new( params )
    @search_unfiltered = Search.new({})

    @projects = @search.results
    @projects_unfiltered = @search_unfiltered.results
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