Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions: 'users_devise_token_auth/sessions',
    registrations: 'users_devise_token_auth/registrations'
  }
  root 'welcome#index'

  get "cookies" => "application#cookies_info", as: :cookies
  get "beta-prospect" => "application#beta_prospect", as: :beta_prospect

  get "dashboard" => "application#dashboard_path_helper"

  get "test_email" => "shipments#test_email"

  resources :contacts, only: [:index, :new, :create, :show, :destroy]
  get "choose_contact" => "contacts#choose", as: :choose_contacts
  get "contact_data/:id" => "contacts#contact_data", as: :contact_data
  namespace :admin do
    resources :shipments do
      collection do
        get "email_action"
      end
    end
    resources :trucking, only: [:index]
    post "trucking/trucking_zip_pricings", to: "trucking#overwrite_zip_trucking"
    post "trucking/trucking_city_pricings", to: "trucking#overwrite_city_trucking"
    resources :hubs, only: [:index, :show] do
      patch "set_status"
    end
    post "hubs/process_csv", to: "hubs#overwrite", as: :hubs_overwrite

    resources :routes, only: [:index, :show]
    get 'client_pricings/:id', to: "pricings#client"
    get 'route_pricings/:id', to: "pricings#route"
    post "routes/process_csv", to: "routes#overwrite", as: :routes_overwrite
    resources :vehicle_types, only: [:index]
    resources :clients, only: [:index, :show]
    resources :pricings, only: [:index]
    post "pricings/ocean_lcl_pricings/process_csv", to: "pricings#overwrite_lcl_carriage", as: :main_lcl_carriage_pricings_overwrite
    post "pricings/ocean_fcl_pricings/process_csv", to: "pricings#overwrite_fcl_carriage", as: :main_fcl_carriage_pricings_overwrite
    post "pricings/update/:id", to: "pricings#update_price"

    resources :open_pricings, only: [:index]
    
    post "open_pricings/train_and_ocean_pricings/process_csv", to: "open_pricings#overwrite_main_carriage", as: :open_main_carriage_pricings_overwrite

    resources :service_charges, only: [:index, :update]
    post "service_charges/process_csv", to: "service_charges#overwrite", as: :service_charges_overwrite

    resources :discounts, only: [:index]
    get "discounts/users/:user_id", to: "discounts#user_routes", as: :discounts_user_routes
    post "discounts/users/:user_id", to: "discounts#create_multiple", as: :discounts_create_multiple

    resources :schedules, only: [:index]
    post "train_schedules/process_csv", to: "schedules#overwrite_trains", as: :schedules_train_overwrite
    post "vessel_schedules/process_csv", to: "schedules#overwrite_vessels", as: :schedules_vessel_overwrite
    post "air_schedules/process_csv", to: "schedules#overwrite_air", as: :schedules_air_overwrite
    get 'hubs', to: 'hubs#index'
    get 'dashboard', to: 'dashboard#index'
    post 'schedules/auto_generate', to: 'schedules#auto_generate_schedules'
  end
  post "users/guest_login", to: "users#anon_login"
  resources :users do
    get "home", as: :home
    get "account", as: :account
    get "hubs", as: :hubs
    put "update", as: :update


    resources :locations, controller: :user_locations, only: [:index, :create, :update, :destroy]

    resources :shipments do
      resources :generic, only: [:index, :new] do
        get "reuse_booking_data", as: :reuse_booking
      end

      resources :fcl do
        get "reuse_booking_data", as: :reuse_booking
        post "get_offer", as: :get_offer
        post "set_haulage", as: :set_haulage
        get "choose_offer", as: :choose_offer
        get "finish_booking", as: :finish_booking
      end

      resources :lcl do
        get "reuse_booking_data", as: :reuse_booking
        post "get_offer", as: :get_offer
        post "set_haulage", as: :set_haulage
        get "choose_offer", as: :choose_offer
        get "finish_booking", as: :finish_booking
      end

      namespace :open do
        resources :lcl do
          get "reuse_booking_data", as: :reuse_booking
          post "get_offer", as: :get_offer
          post "set_haulage", as: :set_haulage
          get "choose_offer", as: :choose_offer
          get "finish_booking", as: :finish_booking
        end
      end
    end
  end

  resources :shipments, only: [:index, :new, :show, :create] do
    get "reuse_booking_data", as: :reuse_booking
    post "get_offer", as: :get_offer
    post "set_haulage", as: :set_haulage
    get "choose_offer", as: :choose_offer
    post "finish_booking", as: :finish_booking
    post "update", as: :update_booking
  end
  get "/documents/delete/:document_id", to: "documents#delete", as: :document_delete
  get "/documents/download/:document_id", to: "documents#download_redirect", as: :document_download
  get "/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading", controller: :pdfs, action: :bill_of_lading, as: :user_shipment_bill_of_lading
  post "shipments/:shipment_id/upload/:type", to: 'shipments#upload_document'
  get "tenants/:name" => "tenants#get_tenant"
end
