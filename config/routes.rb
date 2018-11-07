# frozen_string_literal: true

Rails.application.routes.draw do
  mount Easymon::Engine => '/up'

  get '/health_check', to: 'server_checks#health_check'
  get '/', to: 'server_checks#health_check'

  mount_devise_token_auth_for 'User', at: 'subdomain/:subdomain_id/auth', controllers: {
    sessions: 'users_devise_token_auth/sessions',
    registrations: 'users_devise_token_auth/registrations',
    confirmations: 'users_devise_token_auth/confirmations',
    passwords: 'users_devise_token_auth/passwords'
  }, skip: [:omniauth_callbacks]

  resources :subdomain, only: [:show] do
    namespace :admin do
      resources :shipments do
        collection do
          get 'email_action'
        end
      end
      get 'shipments/pages/delta_page_handler', to: 'shipments#delta_page_handler'
      get 'search/shipments/:target', to: 'shipments#search_shipments'
      resources :trucking, only: %i(index create show)
      post 'trucking/trucking_zip_pricings',  to: 'trucking#overwrite_zip_trucking'
      post 'trucking/trucking_city_pricings', to: 'trucking#overwrite_city_trucking'
      post 'trucking/trucking_zip_pricings/:id',  to: 'trucking#overwrite_zip_trucking_by_hub'
      post 'trucking/trucking_pricings/:id', to: 'trucking#overwrite_zonal_trucking_by_hub'
      post 'trucking/trucking_city_pricings/:id', to: 'trucking#overwrite_city_trucking_by_hub'
      post 'trucking/:id/edit', to: 'trucking#edit'
      post 'trucking/download', to: 'trucking#download'
      post 'currencies/toggle_mode', to: 'currencies#toggle_mode'
      post 'currencies/set_rates', to: 'currencies#set_rates'
      resources :hubs, only: %i(index show create update) do
        patch 'set_status'
      end
      get  'hubs/all/processed', to: 'hubs#all_hubs'
      post 'hubs/:id/update_mandatory_charges', to: 'hubs#update_mandatory_charges'
      post 'hubs/:hub_id/delete', to: 'hubs#delete'
      post 'hubs/:hub_id/image', to: 'hubs#update_image'
      post 'hubs/process_csv', to: 'hubs#overwrite', as: :hubs_overwrite
      get  'hubs/sheet/download',  to: 'hubs#download_hubs'
      post 'user_managers/assign', to: 'user_managers#assign'
      resources :itineraries, only: %i(index show create destroy) do
        resources :notes, only: :delete
      end
      post 'itineraries/:id/edit_notes', to: 'itineraries#edit_notes'

      resources :pricings, only: %i(index destroy)
      get  'client_pricings/:id', to: 'pricings#client'
      get  'route_pricings/:id',  to: 'pricings#route'
      post 'pricings/download', to: 'pricings#download_pricings'
      post 'pricings/update/:id', to: 'pricings#update_price'
      post 'pricings/test/:id', to: 'pricings#test'
      post 'pricings/train_and_ocean_pricings/process_csv',
           to: 'pricings#overwrite_main_carriage', as: :main_carriage_pricings_overwrite

      post 'itineraries/process_csv', to: 'itineraries#overwrite', as: :itineraries_overwrite
      get 'itineraries/:id/layovers', to: 'schedules#layovers'
      get 'itineraries/:id/stops', to: 'itineraries#stops'
      resources :vehicle_types, only: [:index]
      resources :clients, only: %i(index show create destroy)

      resources :pricings, only: [:index]
      post 'pricings/ocean_lcl_pricings/process_csv', to: 'pricings#overwrite_main_lcl_carriage', as: :main_lcl_carriage_pricings_overwrite
      post 'pricings/ocean_fcl_pricings/process_csv', to: 'pricings#overwrite_main_fcl_carriage', as: :main_fcl_carriage_pricings_overwrite
      post 'pricings/update/:id', to: 'pricings#update_price'
      post 'pricings/assign_dedicated', to: 'pricings#assign_dedicated'

      resources :open_pricings, only: [:index]
      post 'open_pricings/ocean_lcl_pricings/process_csv', to: 'open_pricings#overwrite_main_lcl_carriage', as: :open_main_lcl_carriage_pricings_overwrite
      # post "open_pricings/train_and_ocean_pricings/process_csv",
      # to: "open_pricings#overwrite_main_carriage", as: :open_main_carriage_pricings_overwrite

      resources :local_charges, only: %i(index update)
      post 'local_charges/process_csv',
           to: 'local_charges#overwrite', as: :local_charges_overwrite
      post 'local_charges/:id/edit', to: 'local_charges#edit'
      post 'customs_fees/:id/edit', to: 'local_charges#edit_customs'
      post 'local_charges/download', to: 'local_charges#download_local_charges'
      resources :discounts, only: [:index]
      get  'discounts/users/:user_id', to: 'discounts#user_itineraries', as: :discounts_user_itineraries
      post 'discounts/users/:user_id', to: 'discounts#create_multiple', as: :discounts_create_multiple
      post 'shipments/:id/edit_price', to: 'shipments#edit_price'
      post 'shipments/:id/edit_time', to: 'shipments#edit_time'
      post 'shipments/:id/edit_service_price', to: 'shipments#edit_service_price'

      resources :schedules, only: %i(index show destroy)
      post 'schedules/overwrite/:id', to: 'schedules#schedules_by_itinerary'
      post 'train_schedules/process_csv',
           to: 'schedules#overwrite_trains',
           as: :schedules_train_overwrite
      post 'vessel_schedules/process_csv',
           to: 'schedules#overwrite_vessels',
           as: :schedules_vessel_overwrite
      post 'air_schedules/process_csv',
           to: 'schedules#overwrite_air',
           as: :schedules_air_overwrite
      post 'schedules/auto_generate',
           to: 'schedules#auto_generate_schedules'
      post 'schedules/download', to: 'schedules#download_schedules'
      get 'hubs', to: 'hubs#index'
      get 'search/hubs', to: 'hubs#search'
      get 'search/pricings', to: 'pricings#search'
      get 'search/contacts', to: 'contacts#search'
      get 'dashboard', to: 'dashboard#index'
    end

    resources :users do
      get 'home',    as: :home
      get 'account', as: :account
      get 'hubs',    as: :hubs
      put 'update',  as: :update

      resources :addresses, controller: :user_addresses, only: %i(index create update destroy)
      post 'addresses/:address_id/edit', to: 'user_addresses#edit'
      get 'gdpr/download', to: 'users#download_gdpr'
      post 'opt_out/:target', to: 'users#opt_out'
    end
    get 'pricings', to: 'pricings#index'
    get 'pricings/:id', to: 'pricings#show'
    post 'pricings/:id/request', to: 'pricings#request_dedicated_pricing'
    post 'notes/fetch', to: 'notes#get_notes'
    get 'search/shipments/:target', to: 'shipments#search_shipments'
    get 'shipments/pages/delta_page_handler', to: 'shipments#delta_page_handler'
    post 'create_shipment', controller: 'shipments/booking_process', action: 'create_shipment'
    resources :shipments, only: %i(index show) do
      get 'test_email'
      get 'reuse_booking_data', as: :reuse_booking
      %w(choose_offer get_offers update_shipment request_shipment send_quotes).each do |action|
        post action, controller: 'shipments/booking_process', action: action
      end
      get 'view_more_schedules', controller:  'shipments/booking_process', action: 'view_more_schedules'
      post 'quotations/download', controller: 'shipments/booking_process', action: 'download_quotations'
      post 'shipment/download', controller: 'shipments/booking_process', action: 'download_shipment'
    end

    resources :trucking_availability, only: [:index]
    resources :incoterms, only: [:index]

    resources :nexuses, only: [:index]
    get 'find_nexus', to: 'nexuses#find_nexus'
    get 'currencies/base/:currency', to: 'currencies#get_currencies_for_base'
    get 'countries', to: 'countries#index'
    get 'currencies/refresh/:currency', to: 'currencies#refresh_for_base'
    resources :contacts, only: %i(index show create update)
    post 'contacts/update_contact_address/:id', to: 'contacts#update_contact_address'
    get 'search/contacts', to: 'contacts#search_contacts'
    post 'contacts/new_alias', to: 'contacts#new_alias'
    post 'contacts/delete_alias/:id', to: 'contacts#delete_alias'
    get 'contacts/validations/form', to: 'contacts#is_valid'
    post 'contacts/delete_contact_address/:id', to: 'contacts#delete_contact_address'
    post 'shipments/:shipment_id/upload/:type', to: 'shipments#upload_document'
    post 'search/hscodes', to: 'search#search_hs_codes'
    get '/documents/download/:document_id',
        to: 'documents#download_redirect', as: :document_download
    get '/documents/delete/:document_id', to: 'documents#delete', as: :document_delete
    post '/admin/documents/action/:id', to: 'admin/shipments#document_action'
    delete '/admin/documents/:id', to: 'admin/shipments#document_delete'

    get '/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading',
        controller: :pdfs, action: :bill_of_lading, as: :user_shipment_bill_of_lading
    get 'tenants/:name', to: 'tenants#get_tenant'
    get 'tenants', to: 'tenants#index'

    get 'currencies/get', to: 'users#currencies'
    post 'currencies/set', to: 'users#set_currency'

    get 'search/hscodes/:query' => 'search#search_hs_codes'
    post 'super_admins/new_demo' => 'super_admins#new_demo_site'
    post 'super_admins/upload_image' => 'super_admins#upload_image'
    get 'messaging/get' => 'notifications#index'
    post 'messaging/send' => 'notifications#send_message'

    post 'messaging/data' => 'notifications#shipment_data'
    post 'messaging/shipments' => 'notifications#shipments_data'
    post 'messaging/mark' => 'notifications#mark_as_read'
    post 'clear_shoryuken' => 'application#clear_shoryuken'
  end
end
