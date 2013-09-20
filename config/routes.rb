TsbProjectData::Application.routes.draw do

  # DISABLE SOME ROUTES...
  ###############

  # themes
  match "/themes", :to => 'publish_my_data/errors#routing'
  match "/themes/:id", :to => 'publish_my_data/errors#routing'

  # queries
  match "/queries", :to => 'publish_my_data/errors#routing'
  match "/queries/:id", :to => 'publish_my_data/errors#routing'

  # MOUNT PMD
  ##########
  mount PublishMyData::Engine, at: "/"

end
