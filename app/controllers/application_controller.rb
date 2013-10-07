class ApplicationController < PublishMyData::ApplicationController
  helper PublishMyData::Engine.helpers
  helper :all

  before_filter :set_current_nav_tab

  private

  def set_current_nav_tab
    @current_nav_tab = 'browse'
  end

end