class HomeController < ApplicationController

  private

  def set_current_nav_tab
    @current_nav_tab = 'about'
  end

end