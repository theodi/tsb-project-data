class HomeController < ApplicationController

  #caches_action :index, :about

  def index
    @this_year = DateTime.now.year
    @this_years_projects = get_total_projects_for_this_year(@this_year)
    render layout: 'home'
  end

  def viz
    render layout: nil
  end

  def about
    render layout: 'publish_my_data/application'
  end

  private

  def get_total_projects_for_this_year(year_no)
    results = Tripod::SparqlClient::Query.select("
      PREFIX tsb: <http://tsb-projects.labs.theodi.org/def/>
      PREFIX ptime: <http://purl.org/NET/c4dm/timeline.owl#>
      PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
      select (COUNT(*) as ?count)
      where {

      ?project a tsb:Project .
      ?project tsb:projectDuration ?projectDuration .
      ?projectDuration ptime:start ?projectStartDate .
      ?project tsb:competition ?competition .
      ?competition tsb:priorityArea ?priorityArea .

      FILTER(?projectStartDate >= '#{year_no}-01-01'^^xsd:date) .
      FILTER(?projectStartDate <= '#{year_no}-12-31'^^xsd:date) .

      }
    ")

    results[0]["count"]["value"] rescue 0

  end

end