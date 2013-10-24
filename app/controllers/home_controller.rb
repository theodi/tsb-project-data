class HomeController < ApplicationController

  def index
    render layout: 'home'
  end

  def viz
    render layout: 'home'
  end

  def about
    render layout: 'publish_my_data/application'
  end

end