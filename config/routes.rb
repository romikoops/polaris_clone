Rails.application.routes.draw do
  get "/health_check", to: "server_checks#health_check"


  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions:      'users_devise_token_auth/sessions',
    registrations: 'users_devise_token_auth/registrations'
  }
  
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  namespace :admin do
    resources :shipments do
      collection do
        get "email_action"
      end
    end

    resources :trucking, only: [:index]
    post "trucking/trucking_zip_pricings",  to: "trucking#overwrite_zip_trucking"
    post "trucking/trucking_city_pricings", to: "trucking#overwrite_city_trucking"
    
    resources :hubs, only: [:index, :show] do
      patch "set_status"
    end
    post "hubs/process_csv", to: "hubs#overwrite", as: :hubs_overwrite

    resources :routes, only: [:index, :show]

    resources :pricings, only: [:index]
    get  "client_pricings/:id", to: "pricings#client"
    get  "route_pricings/:id",  to: "pricings#route"
    post "pricings/update/:id", to: "pricings#update_price"
    post "pricings/train_and_ocean_pricings/process_csv", 
      to: "pricings#overwrite_main_carriage", as: :main_carriage_pricings_overwrite
    
    post "routes/process_csv", to: "routes#overwrite", as: :routes_overwrite
  
    resources :vehicle_types, only: [:index]
    resources :clients, only: [:index, :show]

    resources :pricings, only: [:index]
    post "pricings/ocean_lcl_pricings/process_csv", to: "pricings#overwrite_lcl_carriage", as: :main_lcl_carriage_pricings_overwrite
    post "pricings/ocean_fcl_pricings/process_csv", to: "pricings#overwrite_fcl_carriage", as: :main_fcl_carriage_pricings_overwrite
    post "pricings/update/:id", to: "pricings#update_price"

    resources :open_pricings, only: [:index]  
    post "open_pricings/train_and_ocean_pricings/process_csv", 
      to: "open_pricings#overwrite_main_carriage", as: :open_main_carriage_pricings_overwrite

    resources :service_charges, only: [:index, :update]
    post "service_charges/process_csv", 
      to: "service_charges#overwrite", as: :service_charges_overwrite

    resources :discounts, only: [:index]
    get  "discounts/users/:user_id", to: "discounts#user_routes", as: :discounts_user_routes
    post "discounts/users/:user_id", to: "discounts#create_multiple", as: :discounts_create_multiple

    resources :schedules, only: [:index]
    post "train_schedules/process_csv", 
      to: "schedules#overwrite_trains", 
      as: :schedules_train_overwrite
    post "vessel_schedules/process_csv", 
      to: "schedules#overwrite_vessels", 
      as: :schedules_vessel_overwrite
    post "air_schedules/process_csv", 
      to: "schedules#overwrite_air", 
      as: :schedules_air_overwrite
    post 'schedules/auto_generate', 
      to: 'schedules#auto_generate_schedules'
    
    get 'hubs',      to: 'hubs#index'
    get 'dashboard', to: 'dashboard#index'
  end

  resources :users do
    get "home",    as: :home
    get "account", as: :account
    get "hubs",    as: :hubs
    put "update",  as: :update

    resources :locations, controller: :user_locations, only: [:index, :create, :update, :destroy]
  end

  resources :shipments, only: [:index, :new, :show, :create] do
    get  "test_email"
    get  "reuse_booking_data", as: :reuse_booking
    get  "choose_offer",       as: :choose_offer
    post "get_offer",          as: :get_offer
    post "set_haulage",        as: :set_haulage
    post "finish_booking",     as: :finish_booking
    post "update",             as: :update_booking
  end
  resources :contacts, only: [:index, :show, :create, :update]
  post 'contacts/update_contact/:id', to: 'contacts#update_contact'
  post 'contacts/new_alias', to: 'contacts#new_alias'
  post 'contacts/delete_alias/:id', to: 'contacts#delete_alias'
  post "shipments/:shipment_id/upload/:type", to: 'shipments#upload_document'
  post "search/hscodes" => "search#search_hs_codes"
  get "/documents/download/:document_id", 
    to: "documents#download_redirect", as: :document_download
  get "/documents/delete/:document_id", to: "documents#delete", as: :document_delete

  get "/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading", 
    controller: :pdfs, action: :bill_of_lading, as: :user_shipment_bill_of_lading
  get "tenants/:name", to: "tenants#get_tenant"

  get 'currencies/get', to: 'users#currencies'
  post 'currencies/set', to: 'users#set_currency'

  get "search/hscodes/:query" => "search#search_hs_codes"
  post 'super_admins/new_demo' => "super_admins#new_demo_site"
end
