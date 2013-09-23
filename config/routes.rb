TsbProjectData::Application.routes.draw do

  # DISABLE SOME ROUTES...
  #########

  # themes
  match "/themes", :to => 'publish_my_data/errors#routing'
  match "/themes/:id", :to => 'publish_my_data/errors#routing'

  # queries
  match "/queries", :to => 'publish_my_data/errors#routing'
  match "/queries/:id", :to => 'publish_my_data/errors#routing'

  # add some routes
  ##########

  resources :projects, only: [:index]
  match "/id/project/:slug", to: "projects#show"
  root to: "home#index"

  # MOUNT PMD
  ##########
  mount PublishMyData::Engine, at: "/"



end
