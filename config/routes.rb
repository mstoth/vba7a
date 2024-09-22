Rails.application.routes.draw do
  get 'secretary/index'
  get 'secretaries/' => 'secretary#index'
  post '/rate' => 'rater#create', :as => 'rate'
  resources :reviews
  resources :pieces
  get 'venues/slider'
  get 'admins/allusers'
  get 'admins/index'
  get 'admins/groups'
  get 'admins/pieces'
  get 'admins/error'
  get 'admins/venues'
  get 'admins/concerts'
  get 'concerts/duplicate/:id', to: 'concerts#duplicate'
  get 'agent/forgot'
  post 'agent/forgot'
  post 'groups/:id/admit/:gid', to: 'concerts#join'

  resources :pieces
  resources :venues
  resources :password_resets
  resources :login_resets

  post 'password_resets/new'
  get  'password_resets/create'
  get 'login_resets/new'
  get 'login_resets/search'
  get 'login_resets/forgot'

  get "users/search"
  get "users/guest"
  put "users/register_guest"
  get "groups/join"

  resources :groups

  get 'concerts/:id/addpiece/:pid', to: 'concerts#addpiece'
  match "pieces/:id/remove" => "pieces#remove", :via => [:put,:get], :as => :remove_piece

  get 'concerts/:id/book',  to: 'concerts#book'

  match "concerts/:id/reserve" => "concerts#reserve", :via => [:post], :as => :reserve_concert

  match "concerts/printable" => "concerts#printable", :via => [:get], :as => :printable_concerts

#  match "concerts/:id/addpiece/:pid" => "concerts#addpiece", :via => [:get], :as => :addpiece

  resources :concerts


  get "concerts/venues_near"
  get "concerts/printable"
  get "venues/concerts_near"

  get "users/musician"
  get "users/groups_near_me"
  get "users/venues_near_me"
  get "users/stop_notification"

  match "users/join_venue/:id" => "users#join_venue", :via => [:get], :as => :join_venue
  match "users/leave_venue/:id" => "users#leave_venue", :via => [:get], :as => :leave_venue
  match "users/join_group/:id" => "users#join_group", :via => [:get], :as => :join_group
  match "users/leave_group/:id" => "users#leave_group", :via => [:get], :as => :leave_group
  match 'concerts_near_me' => "concerts#near_venue", :via => [:get], :as => :concerts_near_me
  match "concerts/:id/near_venue" => "concerts#near_venue", :via => [:get], :as => :near_venue
  match "concerts/:id/venues_near" => "concerts#venues_near", :via => [:get], :as => :venues_near
  match "venues/:id/concerts_near" => "venues#concerts_near", :via => [:get], :as => :concerts_near

  match "agent/:id/help" => "agent#help", :via => [:get], :as => :help
  match 'about' => "agent#about", :via => [:get], :as => :about
  match 'help' => "agent#help", :via => [:get], :as => :agenthelp
  match 'search' => "agent#search", :via => [:get], :as => :search
  match 'xhome' => "agent#xhome", :via => [:get], :as => :xhome
  match 'home' => "agent#firsthome", :via => [:get], :as => :home

  get "agent/musician"
  get "agent/venue"
  get "agent/error"
  get "agent/home"
  get "agent/about"
  get "agent/search"
  get "agent/help"
  get "agent/contact"

  post "admins/delete_user"
  post "agent/musician"

  get "user_sessions/new"

  resource :account, :controller => "users"

  resources :users

  resources :user_sessions

  match 'login' => "user_sessions#new", :via => [:get], :as => :login

  match 'logout' => "user_sessions#destroy", :via => [:get], :as => :logout

  match 'contact' => "agent#contact", :via => [:get], :as => :contact

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "agent#firsthome"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
