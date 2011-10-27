ActionController::Routing::Routes.draw do |map|

  #map.root :controller => "users", :action => "index"
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.activate '/activate/:id', :controller => 'accounts', :action => 'show'
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.reset_password '/reset_password/:id', :controller => 'passwords', :action => 'edit'
  map.change_password '/change_password', :controller => 'accounts', :action => 'edit'
  map.open_id_complete 'session', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.ask_question '/ask_question', :controller => 'main', :action => 'index'
  map.dashboard '/dashboard/:id', :controller => 'users', :action => 'show'
  #map.site_config '/admin/site_config', :controller => 'admin', :action => 'site_config'
  map.review '/review/*uri', :controller => 'main', :action => 'ask'

  # See how all your routes lay out with "rake routes"
  map.resources :pages
  map.resources :contents
  map.resources :items
  map.resources :ratingactions
  map.resources :scores
  map.resources :scoretypes
  map.resources :reputations
  map.resources :site_configs

  map.resources :users, :member => { :enable => :put } do |users|
    users.resource :account
    users.resources :roles
  end

  map.resource :session
  map.resource :password
  map.resource :email

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.

  #for routing any action name
  #map.connect "admin/:action", :controller => 'admin', :action => /[a-z_]+/i


  map.connect "", :controller => "main", :action => "index"
  map.connect 'search', :controller => "main", :action => "search"
  map.connect 'conversations', :controller => "main", :action => "conversations", :view => "all_conversations"
  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  # Install the default route as the lowest priority.
  map.connect ':controller/:action.:format'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'
end
