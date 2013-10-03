class Search

  attr_accessor :params

  attr_accessor :original_search_string
  attr_accessor :search_string
  attr_accessor :page
  attr_accessor :per_page

  def initialize(params)
    self.params = params # store the raw params
    process_params()
  end

  def results
    Project.search page: self.page, per_page: self.per_page do |search|
      search.query do |query|
        query.string self.search_string
      end
    end
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
  end

  def get_pagination_params
    self.page = params[:page].to_i if params[:page].present?
    self.per_page = params[:per_page].to_i if params[:per_page].present?

    self.page ||= 1
    self.per_page ||= 20
    self.per_page = 100 if self.per_page > 100
  end

end