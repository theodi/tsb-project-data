class ProjectsController < ApplicationController

  # list of projects
  def index

    # TODO: change to use faceted search.
    criteria = Project.all
    @pagination_params = PublishMyData::ResourcePaginationParams.from_request(request)
    @projects = PublishMyData::Paginator.new(criteria, @pagination_params).paginate
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