class ProjectsController < ApplicationController

  # list of projects
  def index

    # TODO: change to use faceted search.
    criteria = Project.all
    @pagination_params = PublishMyData::ResourcePaginationParams.from_request(request)
    @projects = PublishMyData::Paginator.new(criteria, @pagination_params).paginate
  end

end