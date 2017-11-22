Rails.application.routes.draw do
  # devise_for :users, controllers: { sessions: "users_devise/sessions", registrations: "users_devise/registrations" }
  mount_devise_token_auth_for 'User', at: 'auth', controllers: {
    sessions:  'overrides/sessions'
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

    resources :hubs, only: [:index] do
      patch "set_status"
    end
    post "hubs/process_csv", to: "hubs#overwrite", as: :hubs_overwrite

    resources :routes, only: [:index]
    post "routes/process_csv", to: "routes#overwrite", as: :routes_overwrite

    resources :pricings, only: [:index]
    post "pricings/train_and_ocean_pricings/process_csv", to: "pricings#overwrite_main_carriage", as: :main_carriage_pricings_overwrite

    resources :open_pricings, only: [:index]
    post "open_pricings/trucking_pricings", to: "open_pricings#overwrite_trucking", as: :open_trucking_pricing_overwrite
    post "open_pricings/train_and_ocean_pricings/process_csv", to: "open_pricings#overwrite_main_carriage", as: :open_main_carriage_pricings_overwrite

    resources :service_charges, only: [:index]
    post "service_charges/process_csv", to: "service_charges#overwrite", as: :service_charges_overwrite

    resources :discounts, only: [:index]
    get "discounts/users/:user_id", to: "discounts#user_routes", as: :discounts_user_routes
    post "discounts/users/:user_id", to: "discounts#create_multiple", as: :discounts_create_multiple

    resources :schedules, only: [:index]
    post "train_schedules/process_csv", to: "schedules#overwrite_trains", as: :schedules_train_overwrite
    post "vessel_schedules/process_csv", to: "schedules#overwrite_vessels", as: :schedules_vessel_overwrite
    post "air_schedules/process_csv", to: "schedules#overwrite_air", as: :schedules_air_overwrite

    # resources :train_schedules, only: [:index]
    # post "train_schedules/process_csv", to: "train_schedules#overwrite", as: :train_schedules_overwrite

    # resources :vessel_schedules, only: [:index]
    # post "vessel_schedules/process_csv", to: "vessel_schedules#overwrite", as: :vessel_schedules_overwrite
  end

  resources :users do
    get "home", as: :home
    get "account", as: :account
    
    resources :locations, only: [:index, :show]
    
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
    end
  get "/documents/download/:document_id", to: "documents#download_redirect", as: :document_download
  get "/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading", controller: :pdfs, action: :bill_of_lading, as: :user_shipment_bill_of_lading

  get "tenants/:name" => "tenants#get_tenant"
end
