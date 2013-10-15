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

        unpaginated_results = @search.results(unpaginated: true)

        @output_csv = CSV.generate(:row_sep => "\r\n") do |csv|

          #headers
          csv << Project.csv_headers

          #data
          unpaginated_results.each do |result|
            Project.csv_data(result.uri).each { |row| csv << row }
          end

        end

        render csv: @output_csv
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