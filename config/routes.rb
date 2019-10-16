# frozen_string_literal: true

Rails.application.routes.draw do
  mount Easymon::Engine, at: '/up'

  mount ApiAuth::Engine, at: '/'
  mount Api::Engine, at: '/'
  mount ApiDocs::Engine, at: '/'

  mount Admiralty::Engine, at: '/admiralty'

  mount_devise_token_auth_for 'User', at: 'tenants/:tenant_id/auth', controllers: {
    sessions: 'users_devise_token_auth/sessions',
    registrations: 'users_devise_token_auth/registrations',
    confirmations: 'users_devise_token_auth/confirmations',
    passwords: 'users_devise_token_auth/passwords'
  }, skip: [:omniauth_callbacks]

  resources :tenants, only: %i(index show) do
    collection do
      get :current
    end

    namespace :admin do
      resources :shipments do
        collection do
          get 'email_action'
        end
      end
      resources :tenants, only: [:update]
      resources :remarks, only: %i(index create update destroy)

      get 'shipments/pages/delta_page_handler', to: 'shipments#delta_page_handler'
      get 'search/shipments/:target', to: 'shipments#search_shipments'
      resources :trucking, only: %i(index create show)
      post 'trucking/trucking_zip_pricings',  to: 'trucking#overwrite_zip_trucking'
      post 'trucking/trucking_city_pricings', to: 'trucking#overwrite_city_trucking'
      post 'trucking/trucking_zip_pricings/:id',  to: 'trucking#overwrite_zip_trucking_by_hub'
      post 'trucking/trucking_pricings/:id', to: 'trucking#overwrite_zonal_trucking_by_hub'
      post 'trucking/trucking_city_pricings/:id', to: 'trucking#overwrite_city_trucking_by_hub'
      post 'trucking/:id/edit', to: 'trucking#edit'
      post 'clients/agents', to: 'clients#agents'
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
      get 'hubs/search/options', to: 'hubs#options_search'
      post 'user_managers/assign', to: 'user_managers#assign'
      resources :itineraries, only: %i(index show create destroy) do
        resources :notes, only: :delete
      end
      post 'notes/upload', to: 'notes#upload'
      post 'itineraries/:id/edit_notes', to: 'itineraries#edit_notes'

      resources :pricings, only: %i(index destroy) do
        collection do
          post :upload
          post :download
        end
      end

      resources :scopes, only: %i(index show create destroy)
      resources :margins, only: %i(index show create destroy) do
        collection do
          post :upload
          post :download
        end
      end

      post 'companies/:id/edit_employees', to: 'companies#edit_employees'
      resources :memberships, only: %i(index show create destroy)

      get 'margins/form/data', to: 'margins#form_data'
      get 'margins/test/data', to: 'margins#test'
      get 'margins/form/itineraries', to: 'margins#itinerary_list'
      get 'margins/form/fee_data', to: 'margins#fee_data'
      post 'margins/update/multiple', to: 'margins#update_multiple'
      get 'memberships/membership_data', to: 'memberships#membership_data'
      post 'memberships/bulk_edit', to: 'memberships#bulk_edit'
      get 'maps/editor_map_data', to: 'maps#editor_map_data'
      get 'maps/geojsons', to: 'maps#geojsons'
      get 'maps/geojson', to: 'maps#geojson'
      post 'maps/country_overlay', to: 'maps#country_overlay'
      get  'client_pricings/:id', to: 'pricings#client'
      get  'route_pricings/:id',  to: 'pricings#route'
      get  'group_pricings/:id',  to: 'pricings#group'
      post 'pricings/update/:id', to: 'pricings#update_price'
      post 'pricings/test/:id', to: 'pricings#test'
      post 'pricings/train_and_ocean_pricings/process_csv',
           to: 'pricings#overwrite_main_carriage', as: :main_carriage_pricings_overwrite
      post 'pricings/update/:id', to: 'pricings#update_price'
      post 'pricings/:id/disable', to: 'pricings#disable'
      post 'pricings/assign_dedicated', to: 'pricings#assign_dedicated'
      post 'itineraries/process_csv', to: 'itineraries#overwrite', as: :itineraries_overwrite
      get 'itineraries/:id/layovers', to: 'schedules#layovers'
      get 'itineraries/:id/stops', to: 'itineraries#stops'
      resources :vehicle_types, only: [:index]
      resources :clients, only: %i(index show create destroy)
      resources :companies, only: %i(index show create destroy)
      resources :groups, only: %i(index show create destroy) do
        member do
          post :edit_members
        end
        collection do
          get :with_margins
        end
      end

      resources :open_pricings, only: [:index]
      post 'open_pricings/ocean_lcl_pricings/process_csv', to: 'open_pricings#overwrite_main_lcl_carriage', as: :open_main_lcl_carriage_pricings_overwrite
      post 'shipments/:shipment_id/upload/:type', to: 'shipments#upload_client_document'
      resources :local_charges, only: %i(index update destroy) do
        collection do
          post :upload
          post :download
          get :group
        end
        member do
          post :edit
        end
      end
      resources :charge_categories, only: %i(index update) do
        collection do
          post :upload
          get :download
        end
      end
      get 'local_charges/:id/hub', to: 'local_charges#hub_charges'
      # post 'local_charges/:id/edit', to: 'local_charges#edit'
      post 'customs_fees/:id/edit', to: 'local_charges#edit_customs'
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
      post 'schedules/auto_generate_sheet',
           to: 'schedules#generate_schedules_from_sheet'
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
      get 'toggle_sandbox',  as: :toggle_sandbox

      resources :addresses, controller: :user_addresses, only: %i(index create update destroy)
      post 'addresses/:address_id/edit', to: 'user_addresses#edit'
      get 'gdpr/download', to: 'users#download_gdpr'
      post 'opt_out/:target', to: 'users#opt_out'
    end

    namespace :itineraries do
      resource :last_available_date, only: :show
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
    resources :locations, only: [:index]
    resources :nexuses, only: [:index]
    get 'find_nexus', to: 'nexuses#find_nexus'
    get 'currencies/base/:currency', to: 'currencies#get_currencies_for_base'
    get 'countries', to: 'countries#index'
    get 'currencies/refresh/:currency', to: 'currencies#refresh_for_base'
    resources :contacts, only: %i(index show create update)
    post 'contacts/update_contact_address/:id', to: 'contacts#update_contact_address'
    get 'search/contacts', to: 'contacts#search_contacts'
    get 'contacts/validations/form', to: 'contacts#is_valid'
    post 'contacts/delete_contact_address/:id', to: 'contacts#delete_contact_address'
    post 'shipments/:shipment_id/upload/:type', to: 'shipments#upload_document'
    post 'search/hscodes', to: 'search#search_hs_codes'
    get '/documents/download/:document_id',
        to: 'documents#download_redirect', as: :document_download
    get '/documents/delete/:document_id', to: 'documents#delete', as: :document_delete
    post '/admin/documents/action/:id', to: 'admin/shipments#document_action'
    delete '/admin/documents/:id', to: 'admin/shipments#document_delete'
    get '/tenants/scope/refresh', to: 'tenants#fetch_scope'
    get '/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading',
        controller: :pdfs, action: :bill_of_lading, as: :user_shipment_bill_of_lading
    get 'tenants/:name', to: 'tenants#get_tenant'

    get 'quotations/download/:id', to: 'quotations#download_pdf'
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
    get 'content/component/:component' => 'contents#component'
    get 'booking_process/contacts', to: 'contacts#booking_process'
  end
end
