# frozen_string_literal: true

Rails.application.routes.draw do
  mount Easymon::Engine, at: '/up'
  mount Api::Engine, at: '/'
  mount Admiralty::Engine, at: '/admiralty'

  mount_devise_token_auth_for 'User', at: 'tenants/:tenant_id/auth', controllers: {
    sessions: 'users_devise_token_auth/sessions',
    registrations: 'users_devise_token_auth/registrations',
    confirmations: 'users_devise_token_auth/confirmations',
    passwords: 'users_devise_token_auth/passwords'
  }, skip: [:omniauth_callbacks]

  namespace :saml do
    get :init
    get :metadata
    post :consume
  end

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
      post 'hubs/process_csv', to: 'hubs#upload', as: :hubs_overwrite
      get  'hubs/sheet/download',  to: 'hubs#download'
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
      post 'margins/test/data', to: 'margins#test'
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
      post 'schedules/upload', to: 'schedules#upload'
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
      get 'show',    as: :show
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
      get 'refresh_quotes', controller: 'shipments/booking_process', action: 'refresh_quotes'
      patch 'update_user', on: :member
    end

    resources :trucking_availability, only: [:index]
    resources :incoterms, only: [:index]
    resources :locations, only: [:index]
    resources :nexuses, only: [:index]
    get 'currencies/base/:currency', to: 'currencies#currencies_for_base'
    get 'countries', to: 'countries#index'
    get 'currencies/refresh/:currency', to: 'currencies#refresh_for_base'
    resources :contacts, only: %i(index show create update)
    post 'contacts/update_contact_address/:id', to: 'contacts#update_contact_address'
    get 'search/contacts', to: 'contacts#search_contacts'
    get 'contacts/validations/form', to: 'contacts#is_valid'
    post 'contacts/delete_contact_address/:id', to: 'contacts#delete_contact_address'
    post 'shipments/:shipment_id/upload/:type', to: 'shipments#upload_document'
    get '/documents/download/:document_id',
        to: 'documents#download_redirect', as: :document_download
    get '/documents/download_url/:document_id', to: 'documents#download_url'
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

# == Route Map
#
#                                                 Prefix Verb   URI Pattern                                                                              Controller#Action
#                                         google_sign_in        /google_sign_in                                                                          GoogleSignIn::Engine
#                                                easymon        /up                                                                                      Easymon::Engine
#                                                    api        /                                                                                        Api::Engine
#                                              admiralty        /admiralty                                                                               Admiralty::Engine
#                                       new_user_session GET    /tenants/:tenant_id/auth/sign_in(.:format)                                               users_devise_token_auth/sessions#new
#                                           user_session POST   /tenants/:tenant_id/auth/sign_in(.:format)                                               users_devise_token_auth/sessions#create
#                                   destroy_user_session DELETE /tenants/:tenant_id/auth/sign_out(.:format)                                              users_devise_token_auth/sessions#destroy
#                                      new_user_password GET    /tenants/:tenant_id/auth/password/new(.:format)                                          users_devise_token_auth/passwords#new
#                                     edit_user_password GET    /tenants/:tenant_id/auth/password/edit(.:format)                                         users_devise_token_auth/passwords#edit
#                                          user_password PATCH  /tenants/:tenant_id/auth/password(.:format)                                              users_devise_token_auth/passwords#update
#                                                        PUT    /tenants/:tenant_id/auth/password(.:format)                                              users_devise_token_auth/passwords#update
#                                                        POST   /tenants/:tenant_id/auth/password(.:format)                                              users_devise_token_auth/passwords#create
#                               cancel_user_registration GET    /tenants/:tenant_id/auth/cancel(.:format)                                                users_devise_token_auth/registrations#cancel
#                                  new_user_registration GET    /tenants/:tenant_id/auth/sign_up(.:format)                                               users_devise_token_auth/registrations#new
#                                 edit_user_registration GET    /tenants/:tenant_id/auth/edit(.:format)                                                  users_devise_token_auth/registrations#edit
#                                      user_registration PATCH  /tenants/:tenant_id/auth(.:format)                                                       users_devise_token_auth/registrations#update
#                                                        PUT    /tenants/:tenant_id/auth(.:format)                                                       users_devise_token_auth/registrations#update
#                                                        DELETE /tenants/:tenant_id/auth(.:format)                                                       users_devise_token_auth/registrations#destroy
#                                                        POST   /tenants/:tenant_id/auth(.:format)                                                       users_devise_token_auth/registrations#create
#                                  new_user_confirmation GET    /tenants/:tenant_id/auth/confirmation/new(.:format)                                      users_devise_token_auth/confirmations#new
#                                      user_confirmation GET    /tenants/:tenant_id/auth/confirmation(.:format)                                          users_devise_token_auth/confirmations#show
#                                                        POST   /tenants/:tenant_id/auth/confirmation(.:format)                                          users_devise_token_auth/confirmations#create
#                                                        GET    /tenants/:tenant_id/auth/validate_token(.:format)                                        devise_token_auth/token_validations#validate_token
#                                              saml_init GET    /saml/init(.:format)                                                                     saml#init
#                                          saml_metadata GET    /saml/metadata(.:format)                                                                 saml#metadata
#                                           saml_consume POST   /saml/consume(.:format)                                                                  saml#consume
#                                        current_tenants GET    /tenants/current(.:format)                                                               tenants#current
#                    email_action_tenant_admin_shipments GET    /tenants/:tenant_id/admin/shipments/email_action(.:format)                               admin/shipments#email_action
#                                 tenant_admin_shipments GET    /tenants/:tenant_id/admin/shipments(.:format)                                            admin/shipments#index
#                                                        POST   /tenants/:tenant_id/admin/shipments(.:format)                                            admin/shipments#create
#                                  tenant_admin_shipment GET    /tenants/:tenant_id/admin/shipments/:id(.:format)                                        admin/shipments#show
#                                                        PATCH  /tenants/:tenant_id/admin/shipments/:id(.:format)                                        admin/shipments#update
#                                                        PUT    /tenants/:tenant_id/admin/shipments/:id(.:format)                                        admin/shipments#update
#                                                        DELETE /tenants/:tenant_id/admin/shipments/:id(.:format)                                        admin/shipments#destroy
#                                    tenant_admin_tenant PATCH  /tenants/:tenant_id/admin/tenants/:id(.:format)                                          admin/tenants#update
#                                                        PUT    /tenants/:tenant_id/admin/tenants/:id(.:format)                                          admin/tenants#update
#                                   tenant_admin_remarks GET    /tenants/:tenant_id/admin/remarks(.:format)                                              admin/remarks#index
#                                                        POST   /tenants/:tenant_id/admin/remarks(.:format)                                              admin/remarks#create
#                                    tenant_admin_remark PATCH  /tenants/:tenant_id/admin/remarks/:id(.:format)                                          admin/remarks#update
#                                                        PUT    /tenants/:tenant_id/admin/remarks/:id(.:format)                                          admin/remarks#update
#                                                        DELETE /tenants/:tenant_id/admin/remarks/:id(.:format)                                          admin/remarks#destroy
#        tenant_admin_shipments_pages_delta_page_handler GET    /tenants/:tenant_id/admin/shipments/pages/delta_page_handler(.:format)                   admin/shipments#delta_page_handler
#                                                        GET    /tenants/:tenant_id/admin/search/shipments/:target(.:format)                             admin/shipments#search_shipments
#                            tenant_admin_trucking_index GET    /tenants/:tenant_id/admin/trucking(.:format)                                             admin/trucking#index
#                                                        POST   /tenants/:tenant_id/admin/trucking(.:format)                                             admin/trucking#create
#                                  tenant_admin_trucking GET    /tenants/:tenant_id/admin/trucking/:id(.:format)                                         admin/trucking#show
#            tenant_admin_trucking_trucking_zip_pricings POST   /tenants/:tenant_id/admin/trucking/trucking_zip_pricings(.:format)                       admin/trucking#overwrite_zip_trucking
#           tenant_admin_trucking_trucking_city_pricings POST   /tenants/:tenant_id/admin/trucking/trucking_city_pricings(.:format)                      admin/trucking#overwrite_city_trucking
#                                                        POST   /tenants/:tenant_id/admin/trucking/trucking_zip_pricings/:id(.:format)                   admin/trucking#overwrite_zip_trucking_by_hub
#                                                        POST   /tenants/:tenant_id/admin/trucking/trucking_pricings/:id(.:format)                       admin/trucking#overwrite_zonal_trucking_by_hub
#                                                        POST   /tenants/:tenant_id/admin/trucking/trucking_city_pricings/:id(.:format)                  admin/trucking#overwrite_city_trucking_by_hub
#                                                        POST   /tenants/:tenant_id/admin/trucking/:id/edit(.:format)                                    admin/trucking#edit
#                            tenant_admin_clients_agents POST   /tenants/:tenant_id/admin/clients/agents(.:format)                                       admin/clients#agents
#                         tenant_admin_trucking_download POST   /tenants/:tenant_id/admin/trucking/download(.:format)                                    admin/trucking#download
#                    tenant_admin_currencies_toggle_mode POST   /tenants/:tenant_id/admin/currencies/toggle_mode(.:format)                               admin/currencies#toggle_mode
#                      tenant_admin_currencies_set_rates POST   /tenants/:tenant_id/admin/currencies/set_rates(.:format)                                 admin/currencies#set_rates
#                            tenant_admin_hub_set_status PATCH  /tenants/:tenant_id/admin/hubs/:hub_id/set_status(.:format)                              admin/hubs#set_status
#                                      tenant_admin_hubs GET    /tenants/:tenant_id/admin/hubs(.:format)                                                 admin/hubs#index
#                                                        POST   /tenants/:tenant_id/admin/hubs(.:format)                                                 admin/hubs#create
#                                       tenant_admin_hub GET    /tenants/:tenant_id/admin/hubs/:id(.:format)                                             admin/hubs#show
#                                                        PATCH  /tenants/:tenant_id/admin/hubs/:id(.:format)                                             admin/hubs#update
#                                                        PUT    /tenants/:tenant_id/admin/hubs/:id(.:format)                                             admin/hubs#update
#                        tenant_admin_hubs_all_processed GET    /tenants/:tenant_id/admin/hubs/all/processed(.:format)                                   admin/hubs#all_hubs
#                                                        POST   /tenants/:tenant_id/admin/hubs/:id/update_mandatory_charges(.:format)                    admin/hubs#update_mandatory_charges
#                                                        POST   /tenants/:tenant_id/admin/hubs/:hub_id/delete(.:format)                                  admin/hubs#delete
#                                                        POST   /tenants/:tenant_id/admin/hubs/:hub_id/image(.:format)                                   admin/hubs#update_image
#                            tenant_admin_hubs_overwrite POST   /tenants/:tenant_id/admin/hubs/process_csv(.:format)                                     admin/hubs#upload
#                       tenant_admin_hubs_sheet_download GET    /tenants/:tenant_id/admin/hubs/sheet/download(.:format)                                  admin/hubs#download
#                       tenant_admin_hubs_search_options GET    /tenants/:tenant_id/admin/hubs/search/options(.:format)                                  admin/hubs#options_search
#                      tenant_admin_user_managers_assign POST   /tenants/:tenant_id/admin/user_managers/assign(.:format)                                 admin/user_managers#assign
#                               tenant_admin_itineraries GET    /tenants/:tenant_id/admin/itineraries(.:format)                                          admin/itineraries#index
#                                                        POST   /tenants/:tenant_id/admin/itineraries(.:format)                                          admin/itineraries#create
#                                 tenant_admin_itinerary GET    /tenants/:tenant_id/admin/itineraries/:id(.:format)                                      admin/itineraries#show
#                                                        DELETE /tenants/:tenant_id/admin/itineraries/:id(.:format)                                      admin/itineraries#destroy
#                              tenant_admin_notes_upload POST   /tenants/:tenant_id/admin/notes/upload(.:format)                                         admin/notes#upload
#                                                        POST   /tenants/:tenant_id/admin/itineraries/:id/edit_notes(.:format)                           admin/itineraries#edit_notes
#                           upload_tenant_admin_pricings POST   /tenants/:tenant_id/admin/pricings/upload(.:format)                                      admin/pricings#upload
#                         download_tenant_admin_pricings POST   /tenants/:tenant_id/admin/pricings/download(.:format)                                    admin/pricings#download
#                                  tenant_admin_pricings GET    /tenants/:tenant_id/admin/pricings(.:format)                                             admin/pricings#index
#                                   tenant_admin_pricing DELETE /tenants/:tenant_id/admin/pricings/:id(.:format)                                         admin/pricings#destroy
#                                    tenant_admin_scopes GET    /tenants/:tenant_id/admin/scopes(.:format)                                               admin/scopes#index
#                                                        POST   /tenants/:tenant_id/admin/scopes(.:format)                                               admin/scopes#create
#                                     tenant_admin_scope GET    /tenants/:tenant_id/admin/scopes/:id(.:format)                                           admin/scopes#show
#                                                        DELETE /tenants/:tenant_id/admin/scopes/:id(.:format)                                           admin/scopes#destroy
#                            upload_tenant_admin_margins POST   /tenants/:tenant_id/admin/margins/upload(.:format)                                       admin/margins#upload
#                          download_tenant_admin_margins POST   /tenants/:tenant_id/admin/margins/download(.:format)                                     admin/margins#download
#                                   tenant_admin_margins GET    /tenants/:tenant_id/admin/margins(.:format)                                              admin/margins#index
#                                                        POST   /tenants/:tenant_id/admin/margins(.:format)                                              admin/margins#create
#                                    tenant_admin_margin GET    /tenants/:tenant_id/admin/margins/:id(.:format)                                          admin/margins#show
#                                                        DELETE /tenants/:tenant_id/admin/margins/:id(.:format)                                          admin/margins#destroy
#                                                        POST   /tenants/:tenant_id/admin/companies/:id/edit_employees(.:format)                         admin/companies#edit_employees
#                               tenant_admin_memberships GET    /tenants/:tenant_id/admin/memberships(.:format)                                          admin/memberships#index
#                                                        POST   /tenants/:tenant_id/admin/memberships(.:format)                                          admin/memberships#create
#                                tenant_admin_membership GET    /tenants/:tenant_id/admin/memberships/:id(.:format)                                      admin/memberships#show
#                                                        DELETE /tenants/:tenant_id/admin/memberships/:id(.:format)                                      admin/memberships#destroy
#                         tenant_admin_margins_form_data GET    /tenants/:tenant_id/admin/margins/form/data(.:format)                                    admin/margins#form_data
#                         tenant_admin_margins_test_data POST   /tenants/:tenant_id/admin/margins/test/data(.:format)                                    admin/margins#test
#                  tenant_admin_margins_form_itineraries GET    /tenants/:tenant_id/admin/margins/form/itineraries(.:format)                             admin/margins#itinerary_list
#                     tenant_admin_margins_form_fee_data GET    /tenants/:tenant_id/admin/margins/form/fee_data(.:format)                                admin/margins#fee_data
#                   tenant_admin_margins_update_multiple POST   /tenants/:tenant_id/admin/margins/update/multiple(.:format)                              admin/margins#update_multiple
#               tenant_admin_memberships_membership_data GET    /tenants/:tenant_id/admin/memberships/membership_data(.:format)                          admin/memberships#membership_data
#                     tenant_admin_memberships_bulk_edit POST   /tenants/:tenant_id/admin/memberships/bulk_edit(.:format)                                admin/memberships#bulk_edit
#                      tenant_admin_maps_editor_map_data GET    /tenants/:tenant_id/admin/maps/editor_map_data(.:format)                                 admin/maps#editor_map_data
#                             tenant_admin_maps_geojsons GET    /tenants/:tenant_id/admin/maps/geojsons(.:format)                                        admin/maps#geojsons
#                              tenant_admin_maps_geojson GET    /tenants/:tenant_id/admin/maps/geojson(.:format)                                         admin/maps#geojson
#                      tenant_admin_maps_country_overlay POST   /tenants/:tenant_id/admin/maps/country_overlay(.:format)                                 admin/maps#country_overlay
#                                                        GET    /tenants/:tenant_id/admin/client_pricings/:id(.:format)                                  admin/pricings#client
#                                                        GET    /tenants/:tenant_id/admin/route_pricings/:id(.:format)                                   admin/pricings#route
#                                                        GET    /tenants/:tenant_id/admin/group_pricings/:id(.:format)                                   admin/pricings#group
#                                                        POST   /tenants/:tenant_id/admin/pricings/update/:id(.:format)                                  admin/pricings#update_price
#                                                        POST   /tenants/:tenant_id/admin/pricings/test/:id(.:format)                                    admin/pricings#test
#          tenant_admin_main_carriage_pricings_overwrite POST   /tenants/:tenant_id/admin/pricings/train_and_ocean_pricings/process_csv(.:format)        admin/pricings#overwrite_main_carriage
#                                                        POST   /tenants/:tenant_id/admin/pricings/update/:id(.:format)                                  admin/pricings#update_price
#                                                        POST   /tenants/:tenant_id/admin/pricings/:id/disable(.:format)                                 admin/pricings#disable
#                 tenant_admin_pricings_assign_dedicated POST   /tenants/:tenant_id/admin/pricings/assign_dedicated(.:format)                            admin/pricings#assign_dedicated
#                     tenant_admin_itineraries_overwrite POST   /tenants/:tenant_id/admin/itineraries/process_csv(.:format)                              admin/itineraries#overwrite
#                                                        GET    /tenants/:tenant_id/admin/itineraries/:id/layovers(.:format)                             admin/schedules#layovers
#                                                        GET    /tenants/:tenant_id/admin/itineraries/:id/stops(.:format)                                admin/itineraries#stops
#                             tenant_admin_vehicle_types GET    /tenants/:tenant_id/admin/vehicle_types(.:format)                                        admin/vehicle_types#index
#                                   tenant_admin_clients GET    /tenants/:tenant_id/admin/clients(.:format)                                              admin/clients#index
#                                                        POST   /tenants/:tenant_id/admin/clients(.:format)                                              admin/clients#create
#                                    tenant_admin_client GET    /tenants/:tenant_id/admin/clients/:id(.:format)                                          admin/clients#show
#                                                        DELETE /tenants/:tenant_id/admin/clients/:id(.:format)                                          admin/clients#destroy
#                                 tenant_admin_companies GET    /tenants/:tenant_id/admin/companies(.:format)                                            admin/companies#index
#                                                        POST   /tenants/:tenant_id/admin/companies(.:format)                                            admin/companies#create
#                                   tenant_admin_company GET    /tenants/:tenant_id/admin/companies/:id(.:format)                                        admin/companies#show
#                                                        DELETE /tenants/:tenant_id/admin/companies/:id(.:format)                                        admin/companies#destroy
#                        edit_members_tenant_admin_group POST   /tenants/:tenant_id/admin/groups/:id/edit_members(.:format)                              admin/groups#edit_members
#                       with_margins_tenant_admin_groups GET    /tenants/:tenant_id/admin/groups/with_margins(.:format)                                  admin/groups#with_margins
#                                    tenant_admin_groups GET    /tenants/:tenant_id/admin/groups(.:format)                                               admin/groups#index
#                                                        POST   /tenants/:tenant_id/admin/groups(.:format)                                               admin/groups#create
#                                     tenant_admin_group GET    /tenants/:tenant_id/admin/groups/:id(.:format)                                           admin/groups#show
#                                                        DELETE /tenants/:tenant_id/admin/groups/:id(.:format)                                           admin/groups#destroy
#                             tenant_admin_open_pricings GET    /tenants/:tenant_id/admin/open_pricings(.:format)                                        admin/open_pricings#index
# tenant_admin_open_main_lcl_carriage_pricings_overwrite POST   /tenants/:tenant_id/admin/open_pricings/ocean_lcl_pricings/process_csv(.:format)         admin/open_pricings#overwrite_main_lcl_carriage
#                                                        POST   /tenants/:tenant_id/admin/shipments/:shipment_id/upload/:type(.:format)                  admin/shipments#upload_client_document
#                      upload_tenant_admin_local_charges POST   /tenants/:tenant_id/admin/local_charges/upload(.:format)                                 admin/local_charges#upload
#                    download_tenant_admin_local_charges POST   /tenants/:tenant_id/admin/local_charges/download(.:format)                               admin/local_charges#download
#                       group_tenant_admin_local_charges GET    /tenants/:tenant_id/admin/local_charges/group(.:format)                                  admin/local_charges#group
#                         edit_tenant_admin_local_charge POST   /tenants/:tenant_id/admin/local_charges/:id/edit(.:format)                               admin/local_charges#edit
#                             tenant_admin_local_charges GET    /tenants/:tenant_id/admin/local_charges(.:format)                                        admin/local_charges#index
#                              tenant_admin_local_charge PATCH  /tenants/:tenant_id/admin/local_charges/:id(.:format)                                    admin/local_charges#update
#                                                        PUT    /tenants/:tenant_id/admin/local_charges/:id(.:format)                                    admin/local_charges#update
#                                                        DELETE /tenants/:tenant_id/admin/local_charges/:id(.:format)                                    admin/local_charges#destroy
#                  upload_tenant_admin_charge_categories POST   /tenants/:tenant_id/admin/charge_categories/upload(.:format)                             admin/charge_categories#upload
#                download_tenant_admin_charge_categories GET    /tenants/:tenant_id/admin/charge_categories/download(.:format)                           admin/charge_categories#download
#                         tenant_admin_charge_categories GET    /tenants/:tenant_id/admin/charge_categories(.:format)                                    admin/charge_categories#index
#                           tenant_admin_charge_category PATCH  /tenants/:tenant_id/admin/charge_categories/:id(.:format)                                admin/charge_categories#update
#                                                        PUT    /tenants/:tenant_id/admin/charge_categories/:id(.:format)                                admin/charge_categories#update
#                                                        GET    /tenants/:tenant_id/admin/local_charges/:id/hub(.:format)                                admin/local_charges#hub_charges
#                                                        POST   /tenants/:tenant_id/admin/customs_fees/:id/edit(.:format)                                admin/local_charges#edit_customs
#                                 tenant_admin_discounts GET    /tenants/:tenant_id/admin/discounts(.:format)                                            admin/discounts#index
#                tenant_admin_discounts_user_itineraries GET    /tenants/:tenant_id/admin/discounts/users/:user_id(.:format)                             admin/discounts#user_itineraries
#                 tenant_admin_discounts_create_multiple POST   /tenants/:tenant_id/admin/discounts/users/:user_id(.:format)                             admin/discounts#create_multiple
#                                                        POST   /tenants/:tenant_id/admin/shipments/:id/edit_price(.:format)                             admin/shipments#edit_price
#                                                        POST   /tenants/:tenant_id/admin/shipments/:id/edit_time(.:format)                              admin/shipments#edit_time
#                                                        POST   /tenants/:tenant_id/admin/shipments/:id/edit_service_price(.:format)                     admin/shipments#edit_service_price
#                                 tenant_admin_schedules GET    /tenants/:tenant_id/admin/schedules(.:format)                                            admin/schedules#index
#                                  tenant_admin_schedule GET    /tenants/:tenant_id/admin/schedules/:id(.:format)                                        admin/schedules#show
#                                                        DELETE /tenants/:tenant_id/admin/schedules/:id(.:format)                                        admin/schedules#destroy
#                          tenant_admin_schedules_upload POST   /tenants/:tenant_id/admin/schedules/upload(.:format)                                     admin/schedules#upload
#                        tenant_admin_schedules_download POST   /tenants/:tenant_id/admin/schedules/download(.:format)                                   admin/schedules#download_schedules
#             tenant_admin_schedules_auto_generate_sheet POST   /tenants/:tenant_id/admin/schedules/auto_generate_sheet(.:format)                        admin/schedules#generate_schedules_from_sheet
#                                                        GET    /tenants/:tenant_id/admin/hubs(.:format)                                                 admin/hubs#index
#                               tenant_admin_search_hubs GET    /tenants/:tenant_id/admin/search/hubs(.:format)                                          admin/hubs#search
#                           tenant_admin_search_pricings GET    /tenants/:tenant_id/admin/search/pricings(.:format)                                      admin/pricings#search
#                           tenant_admin_search_contacts GET    /tenants/:tenant_id/admin/search/contacts(.:format)                                      admin/contacts#search
#                                 tenant_admin_dashboard GET    /tenants/:tenant_id/admin/dashboard(.:format)                                            admin/dashboard#index
#                                       tenant_user_home GET    /tenants/:tenant_id/users/:user_id/home(.:format)                                        users#home
#                                       tenant_user_show GET    /tenants/:tenant_id/users/:user_id/show(.:format)                                        users#show
#                                    tenant_user_account GET    /tenants/:tenant_id/users/:user_id/account(.:format)                                     users#account
#                                       tenant_user_hubs GET    /tenants/:tenant_id/users/:user_id/hubs(.:format)                                        users#hubs
#                                     tenant_user_update PUT    /tenants/:tenant_id/users/:user_id/update(.:format)                                      users#update
#                             tenant_user_toggle_sandbox GET    /tenants/:tenant_id/users/:user_id/toggle_sandbox(.:format)                              users#toggle_sandbox
#                                  tenant_user_addresses GET    /tenants/:tenant_id/users/:user_id/addresses(.:format)                                   user_addresses#index
#                                                        POST   /tenants/:tenant_id/users/:user_id/addresses(.:format)                                   user_addresses#create
#                                    tenant_user_address PATCH  /tenants/:tenant_id/users/:user_id/addresses/:id(.:format)                               user_addresses#update
#                                                        PUT    /tenants/:tenant_id/users/:user_id/addresses/:id(.:format)                               user_addresses#update
#                                                        DELETE /tenants/:tenant_id/users/:user_id/addresses/:id(.:format)                               user_addresses#destroy
#                                                        POST   /tenants/:tenant_id/users/:user_id/addresses/:address_id/edit(.:format)                  user_addresses#edit
#                              tenant_user_gdpr_download GET    /tenants/:tenant_id/users/:user_id/gdpr/download(.:format)                               users#download_gdpr
#                                                        POST   /tenants/:tenant_id/users/:user_id/opt_out/:target(.:format)                             users#opt_out
#                                           tenant_users GET    /tenants/:tenant_id/users(.:format)                                                      users#index
#                                                        POST   /tenants/:tenant_id/users(.:format)                                                      users#create
#                                            tenant_user GET    /tenants/:tenant_id/users/:id(.:format)                                                  users#show
#                                                        PATCH  /tenants/:tenant_id/users/:id(.:format)                                                  users#update
#                                                        PUT    /tenants/:tenant_id/users/:id(.:format)                                                  users#update
#                                                        DELETE /tenants/:tenant_id/users/:id(.:format)                                                  users#destroy
#                 tenant_itineraries_last_available_date GET    /tenants/:tenant_id/itineraries/last_available_date(.:format)                            itineraries/last_available_dates#show
#                                        tenant_pricings GET    /tenants/:tenant_id/pricings(.:format)                                                   pricings#index
#                                                        GET    /tenants/:tenant_id/pricings/:id(.:format)                                               pricings#show
#                                                        POST   /tenants/:tenant_id/pricings/:id/request(.:format)                                       pricings#request_dedicated_pricing
#                                     tenant_notes_fetch POST   /tenants/:tenant_id/notes/fetch(.:format)                                                notes#get_notes
#                                                        GET    /tenants/:tenant_id/search/shipments/:target(.:format)                                   shipments#search_shipments
#              tenant_shipments_pages_delta_page_handler GET    /tenants/:tenant_id/shipments/pages/delta_page_handler(.:format)                         shipments#delta_page_handler
#                                 tenant_create_shipment POST   /tenants/:tenant_id/create_shipment(.:format)                                            shipments/booking_process#create_shipment
#                             tenant_shipment_test_email GET    /tenants/:tenant_id/shipments/:shipment_id/test_email(.:format)                          shipments#test_email
#                          tenant_shipment_reuse_booking GET    /tenants/:tenant_id/shipments/:shipment_id/reuse_booking_data(.:format)                  shipments#reuse_booking_data
#                           tenant_shipment_choose_offer POST   /tenants/:tenant_id/shipments/:shipment_id/choose_offer(.:format)                        shipments/booking_process#choose_offer
#                             tenant_shipment_get_offers POST   /tenants/:tenant_id/shipments/:shipment_id/get_offers(.:format)                          shipments/booking_process#get_offers
#                        tenant_shipment_update_shipment POST   /tenants/:tenant_id/shipments/:shipment_id/update_shipment(.:format)                     shipments/booking_process#update_shipment
#                       tenant_shipment_request_shipment POST   /tenants/:tenant_id/shipments/:shipment_id/request_shipment(.:format)                    shipments/booking_process#request_shipment
#                            tenant_shipment_send_quotes POST   /tenants/:tenant_id/shipments/:shipment_id/send_quotes(.:format)                         shipments/booking_process#send_quotes
#                    tenant_shipment_view_more_schedules GET    /tenants/:tenant_id/shipments/:shipment_id/view_more_schedules(.:format)                 shipments/booking_process#view_more_schedules
#                    tenant_shipment_quotations_download POST   /tenants/:tenant_id/shipments/:shipment_id/quotations/download(.:format)                 shipments/booking_process#download_quotations
#                      tenant_shipment_shipment_download POST   /tenants/:tenant_id/shipments/:shipment_id/shipment/download(.:format)                   shipments/booking_process#download_shipment
#                         tenant_shipment_refresh_quotes GET    /tenants/:tenant_id/shipments/:shipment_id/refresh_quotes(.:format)                      shipments/booking_process#refresh_quotes
#                            update_user_tenant_shipment PATCH  /tenants/:tenant_id/shipments/:id/update_user(.:format)                                  shipments#update_user
#                                       tenant_shipments GET    /tenants/:tenant_id/shipments(.:format)                                                  shipments#index
#                                        tenant_shipment GET    /tenants/:tenant_id/shipments/:id(.:format)                                              shipments#show
#                     tenant_trucking_availability_index GET    /tenants/:tenant_id/trucking_availability(.:format)                                      trucking_availability#index
#                                       tenant_incoterms GET    /tenants/:tenant_id/incoterms(.:format)                                                  incoterms#index
#                                       tenant_locations GET    /tenants/:tenant_id/locations(.:format)                                                  locations#index
#                                         tenant_nexuses GET    /tenants/:tenant_id/nexuses(.:format)                                                    nexuses#index
#                                                        GET    /tenants/:tenant_id/currencies/base/:currency(.:format)                                  currencies#currencies_for_base
#                                       tenant_countries GET    /tenants/:tenant_id/countries(.:format)                                                  countries#index
#                                                        GET    /tenants/:tenant_id/currencies/refresh/:currency(.:format)                               currencies#refresh_for_base
#                                        tenant_contacts GET    /tenants/:tenant_id/contacts(.:format)                                                   contacts#index
#                                                        POST   /tenants/:tenant_id/contacts(.:format)                                                   contacts#create
#                                         tenant_contact GET    /tenants/:tenant_id/contacts/:id(.:format)                                               contacts#show
#                                                        PATCH  /tenants/:tenant_id/contacts/:id(.:format)                                               contacts#update
#                                                        PUT    /tenants/:tenant_id/contacts/:id(.:format)                                               contacts#update
#                                                        POST   /tenants/:tenant_id/contacts/update_contact_address/:id(.:format)                        contacts#update_contact_address
#                                 tenant_search_contacts GET    /tenants/:tenant_id/search/contacts(.:format)                                            contacts#search_contacts
#                       tenant_contacts_validations_form GET    /tenants/:tenant_id/contacts/validations/form(.:format)                                  contacts#is_valid
#                                                        POST   /tenants/:tenant_id/contacts/delete_contact_address/:id(.:format)                        contacts#delete_contact_address
#                                                        POST   /tenants/:tenant_id/shipments/:shipment_id/upload/:type(.:format)                        shipments#upload_document
#                               tenant_document_download GET    /tenants/:tenant_id/documents/download/:document_id(.:format)                            documents#download_redirect
#                                                        GET    /tenants/:tenant_id/documents/download_url/:document_id(.:format)                        documents#download_url
#                                 tenant_document_delete GET    /tenants/:tenant_id/documents/delete/:document_id(.:format)                              documents#delete
#                                                        POST   /tenants/:tenant_id/admin/documents/action/:id(.:format)                                 admin/shipments#document_action
#                                                        DELETE /tenants/:tenant_id/admin/documents/:id(.:format)                                        admin/shipments#document_delete
#                           tenant_tenants_scope_refresh GET    /tenants/:tenant_id/tenants/scope/refresh(.:format)                                      tenants#fetch_scope
#                    tenant_user_shipment_bill_of_lading GET    /tenants/:tenant_id/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading(.:format)   pdfs#bill_of_lading
#                                                        GET    /tenants/:tenant_id/tenants/:name(.:format)                                              tenants#get_tenant
#                                                        GET    /tenants/:tenant_id/quotations/download/:id(.:format)                                    quotations#download_pdf
#                                  tenant_currencies_get GET    /tenants/:tenant_id/currencies/get(.:format)                                             users#currencies
#                                  tenant_currencies_set POST   /tenants/:tenant_id/currencies/set(.:format)                                             users#set_currency
#                           tenant_super_admins_new_demo POST   /tenants/:tenant_id/super_admins/new_demo(.:format)                                      super_admins#new_demo_site
#                       tenant_super_admins_upload_image POST   /tenants/:tenant_id/super_admins/upload_image(.:format)                                  super_admins#upload_image
#                                   tenant_messaging_get GET    /tenants/:tenant_id/messaging/get(.:format)                                              notifications#index
#                                  tenant_messaging_send POST   /tenants/:tenant_id/messaging/send(.:format)                                             notifications#send_message
#                                  tenant_messaging_data POST   /tenants/:tenant_id/messaging/data(.:format)                                             notifications#shipment_data
#                             tenant_messaging_shipments POST   /tenants/:tenant_id/messaging/shipments(.:format)                                        notifications#shipments_data
#                                  tenant_messaging_mark POST   /tenants/:tenant_id/messaging/mark(.:format)                                             notifications#mark_as_read
#                                 tenant_clear_shoryuken POST   /tenants/:tenant_id/clear_shoryuken(.:format)                                            application#clear_shoryuken
#                                                        GET    /tenants/:tenant_id/content/component/:component(.:format)                               contents#component
#                        tenant_booking_process_contacts GET    /tenants/:tenant_id/booking_process/contacts(.:format)                                   contacts#booking_process
#                                                tenants GET    /tenants(.:format)                                                                       tenants#index
#                                                 tenant GET    /tenants/:id(.:format)                                                                   tenants#show
#                                     rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#                              rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                                     rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#                              update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                                   rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create
# 
# Routes for GoogleSignIn::Engine:
# authorization POST /authorization(.:format) google_sign_in/authorizations#create
#      callback GET  /callback(.:format)      google_sign_in/callbacks#show
# 
# Routes for Easymon::Engine:
#        GET  /(.:format)       easymon/checks#index
#   root GET  /                 easymon/checks#index
#        GET  /:check(.:format) easymon/checks#show
# 
# Routes for ApiAuth::Engine:
#      oauth_token POST   /oauth/token(.:format)      api_auth/tokens#create
#     oauth_revoke POST   /oauth/revoke(.:format)     api_auth/tokens#revoke
# oauth_introspect POST   /oauth/introspect(.:format) api_auth/tokens#introspect
# oauth_token_info GET    /oauth/token/info(.:format) api_auth/token_info#show
#    oauth_signout DELETE /oauth/signout(.:format)    api_auth/auth#destroy
# 
# Routes for ApiDocs::Engine:
# raddocs_app      /docs       Raddocs::App
# 
# Routes for Api::Engine:
#                       api_auth        /                                                    ApiAuth::Engine
#                          v1_me GET    /v1/me(.:format)                                     api/v1/users#show
#                     v1_clients GET    /v1/clients(.:format)                                api/v1/clients#index
#                                POST   /v1/clients(.:format)                                api/v1/clients#create
#                      v1_client GET    /v1/clients/:id(.:format)                            api/v1/clients#show
#                  v1_equipments GET    /v1/equipments(.:format)                             api/v1/equipments#index
#                scope_v1_tenant GET    /v1/tenants/:id/scope(.:format)                      api/v1/tenants#scope
#            countries_v1_tenant GET    /v1/tenants/:id/countries(.:format)                  api/v1/tenants#countries
#                     v1_tenants GET    /v1/tenants(.:format)                                api/v1/tenants#index
#                   v1_dashboard GET    /v1/dashboard(.:format)                              api/v1/dashboard#show
#            v1_quotation_create POST   /v1/quotations/:quotation_id/create(.:format)        api/v1/quotations#create
#          v1_quotation_download POST   /v1/quotations/:quotation_id/download(.:format)      api/v1/quotations#download
#            v1_quotation_charge GET    /v1/quotations/:quotation_id/charges/:id(.:format)   api/v1/charges#show
#          v1_quotation_schedule GET    /v1/quotations/:quotation_id/schedules/:id(.:format) api/v1/schedules#show
#                  v1_quotations GET    /v1/quotations(.:format)                             api/v1/quotations#index
#                                POST   /v1/quotations(.:format)                             api/v1/quotations#create
#                   v1_quotation GET    /v1/quotations/:id(.:format)                         api/v1/quotations#show
#                                PATCH  /v1/quotations/:id(.:format)                         api/v1/quotations#update
#                                PUT    /v1/quotations/:id(.:format)                         api/v1/quotations#update
#                                DELETE /v1/quotations/:id(.:format)                         api/v1/quotations#destroy
#                      v1_tender PATCH  /v1/tenders/:id(.:format)                            api/v1/tenders#update
#                                PUT    /v1/tenders/:id(.:format)                            api/v1/tenders#update
#            v1_cargo_item_types GET    /v1/cargo_item_types(.:format)                       api/v1/cargo_item_types#index
# v1_trucking_availability_index GET    /v1/trucking_availability(.:format)                  api/v1/trucking_availability#index
#                      v1_groups GET    /v1/groups(.:format)                                 api/v1/tenants_groups#index
#           origins_v1_locations GET    /v1/locations/origins(.:format)                      api/v1/locations#origins
#      destinations_v1_locations GET    /v1/locations/destinations(.:format)                 api/v1/locations#destinations
#                   v1_locations GET    /v1/locations(.:format)                              api/v1/locations#index
#                                POST   /v1/locations(.:format)                              api/v1/locations#create
#                    v1_location GET    /v1/locations/:id(.:format)                          api/v1/locations#show
#                                PATCH  /v1/locations/:id(.:format)                          api/v1/locations#update
#                                PUT    /v1/locations/:id(.:format)                          api/v1/locations#update
#                                DELETE /v1/locations/:id(.:format)                          api/v1/locations#destroy
#               settings_v1_ahoy GET    /v1/ahoy/:id/settings(.:format)                      api/v1/ahoy#settings
#                                GET    /v1/itineraries/ports/:tenant_uuid(.:format)         api/v1/itineraries#ports
#                 v1_itineraries GET    /v1/itineraries(.:format)                            api/v1/itineraries#index
#                       api_docs        /                                                    ApiDocs::Engine
# 
# Routes for AdmiraltyAuth::Engine:
#        login GET    /login(.:format)        admiralty_auth/logins#new
# create_login GET    /login/create(.:format) admiralty_auth/logins#create
# delete_login DELETE /login(.:format)        admiralty_auth/logins#destroy
# 
# Routes for AdmiraltyReports::Engine:
#        reports GET  /reports(.:format)        admiralty_reports/reports#index
#         report GET  /reports/:id(.:format)    admiralty_reports/reports#show
# download_stats GET  /stats/download(.:format) admiralty_reports/stats#download
# 
# Routes for AdmiraltyTenants::Engine:
#     tenants GET   /tenants(.:format)          admiralty_tenants/tenants#index
#             POST  /tenants(.:format)          admiralty_tenants/tenants#create
#  new_tenant GET   /tenants/new(.:format)      admiralty_tenants/tenants#new
# edit_tenant GET   /tenants/:id/edit(.:format) admiralty_tenants/tenants#edit
#      tenant GET   /tenants/:id(.:format)      admiralty_tenants/tenants#show
#             PATCH /tenants/:id(.:format)      admiralty_tenants/tenants#update
#             PUT   /tenants/:id(.:format)      admiralty_tenants/tenants#update
# 
# Routes for Admiralty::Engine:
#    admiralty_auth      /           AdmiraltyAuth::Engine
# admiralty_reports      /           AdmiraltyReports::Engine
# admiralty_tenants      /           AdmiraltyTenants::Engine
#              root GET  /           admiralty/dashboard#index
