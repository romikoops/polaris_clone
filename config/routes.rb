# frozen_string_literal: true

Rails.application.routes.draw do
  mount Easymon::Engine, at: "/up"
  get "/healthz", to: "application#health"
  get "/ping/version", to: proc { [200, {}, [(ENV["RELEASE"]).to_s]] }
  mount Rswag::Api::Engine, at: "/specs"

  get "/sidekiq", to: redirect("/admin/sidekiq", status: 301)

  resource :user, only: %i[show create] do
    collection do
      post :passwordless_authentication
    end
  end

  resources :organizations, only: %i[index show] do
    resources :password_resets, only: %i[create edit update]

    collection do
      get :current
    end

    namespace :admin do
      resources :shipments do
        collection do
          get "email_action"
        end
      end
      resources :organizations, only: [:update]
      resources :remarks, only: %i[index create update destroy]

      get "shipments/pages/delta_page_handler", to: "shipments#delta_page_handler"
      get "search/shipments/:target", to: "shipments#search_shipments"
      resources :trucking, only: %i[index create show]
      post "trucking/trucking_zip_pricings", to: "trucking#overwrite_zip_trucking"
      post "trucking/trucking_city_pricings", to: "trucking#overwrite_city_trucking"
      post "trucking/trucking_zip_pricings/:id", to: "trucking#overwrite_zip_trucking_by_hub"
      post "trucking/trucking_pricings/:id", to: "trucking#upload"
      post "trucking/trucking_city_pricings/:id", to: "trucking#overwrite_city_trucking_by_hub"
      post "trucking/:id/edit", to: "trucking#edit"
      post "clients/agents", to: "clients#agents"
      post "trucking/download", to: "trucking#download"
      post "currencies/toggle_mode", to: "currencies#toggle_mode"
      post "currencies/set_rates", to: "currencies#set_rates"
      resources :hubs, only: %i[index show create update] do
        patch "set_status"
      end
      get "hubs/all/processed", to: "hubs#all_hubs"
      post "hubs/:id/update_mandatory_charges", to: "hubs#update_mandatory_charges"
      post "hubs/:hub_id/delete", to: "hubs#delete"
      post "hubs/:hub_id/image", to: "hubs#update_image"
      post "hubs/process_csv", to: "hubs#upload", as: :hubs_overwrite
      get "hubs/sheet/download", to: "hubs#download"
      get "hubs/search/options", to: "hubs#options_search"
      post "user_managers/assign", to: "user_managers#assign"
      resources :itineraries, only: %i[index show create destroy] do
        resources :notes, only: :delete
      end
      post "notes/upload", to: "notes#upload"
      post "itineraries/:id/edit_notes", to: "itineraries#edit_notes"

      resources :pricings, only: %i[index destroy] do
        collection do
          post :upload
          post :download
        end
      end

      resources :margins, only: %i[index show create destroy] do
        collection do
          post :upload
          post :download
        end
      end

      post "companies/:id/edit_employees", to: "companies#edit_employees"
      resources :memberships, only: %i[index show create destroy]

      get "margins/form/data", to: "margins#form_data"
      post "margins/test/data", to: "margins#test"
      get "margins/form/itineraries", to: "margins#itinerary_list"
      get "margins/form/fee_data", to: "margins#fee_data"
      post "margins/update/multiple", to: "margins#update_multiple"
      post "memberships/bulk_edit", to: "memberships#bulk_edit"
      get "maps/editor_map_data", to: "maps#editor_map_data"
      get "maps/geojsons", to: "maps#geojsons"
      get "maps/geojson", to: "maps#geojson"
      post "maps/country_overlay", to: "maps#country_overlay"
      get "client_pricings/:id", to: "pricings#client"
      get "route_pricings/:id", to: "pricings#route"
      get "group_pricings/:id", to: "pricings#group"
      post "pricings/update/:id", to: "pricings#update_price"
      post "pricings/test/:id", to: "pricings#test"
      post "pricings/train_and_ocean_pricings/process_csv",
        to: "pricings#overwrite_main_carriage", as: :main_carriage_pricings_overwrite
      post "pricings/update/:id", to: "pricings#update_price"
      post "pricings/:id/disable", to: "pricings#disable"
      post "pricings/assign_dedicated", to: "pricings#assign_dedicated"
      post "itineraries/process_csv", to: "itineraries#overwrite", as: :itineraries_overwrite
      get "itineraries/:id/layovers", to: "schedules#layovers"
      get "itineraries/:id/stops", to: "itineraries#stops"
      resources :vehicle_types, only: [:index]
      resources :clients, only: %i[index show create destroy]
      resources :companies, only: %i[index show create destroy]
      resources :groups, only: %i[index show create destroy update] do
        member do
          post :edit_members
        end
        collection do
          get :with_margins
        end
      end

      resources :open_pricings, only: [:index]
      post "open_pricings/ocean_lcl_pricings/process_csv", to: "open_pricings#overwrite_main_lcl_carriage",
                                                           as: :open_main_lcl_carriage_pricings_overwrite
      post "shipments/:shipment_id/upload/:type", to: "shipments#upload_client_document"
      resources :local_charges, only: %i[index update destroy] do
        collection do
          post :upload
          post :download
          get :group
        end
        member do
          post :edit
        end
      end
      resources :charge_categories, only: %i[index update] do
        collection do
          post :upload
          get :download
        end
      end
      get "local_charges/:id/hub", to: "local_charges#hub_charges"
      # post 'local_charges/:id/edit', to: 'local_charges#edit'
      post "customs_fees/:id/edit", to: "local_charges#edit_customs"
      resources :discounts, only: [:index]
      get "discounts/users/:user_id", to: "discounts#user_itineraries", as: :discounts_user_itineraries
      post "discounts/users/:user_id", to: "discounts#create_multiple", as: :discounts_create_multiple
      post "shipments/:id/edit_price", to: "shipments#edit_price"
      post "shipments/:id/edit_time", to: "shipments#edit_time"
      post "shipments/:id/edit_service_price", to: "shipments#edit_service_price"

      resources :schedules, only: %i[index show destroy]
      post "schedules/upload", to: "schedules#upload"
      post "schedules/download", to: "schedules#download_schedules"
      post "schedules/auto_generate", to: "schedules#auto_generate_schedules"
      post "schedules/auto_generate_sheet",
        to: "schedules#generate_schedules_from_sheet"
      get "hubs", to: "hubs#index"
      get "search/hubs", to: "hubs#search"
      get "search/pricings", to: "pricings#search"
      get "search/contacts", to: "contacts#search"
      get "dashboard", to: "dashboard#index"
    end
    resources :users do
      member do
        get :activate
      end
      collection do
        post :passwordless_authentication
      end
      get "home", as: :home
      get "show", as: :show
      get "account", as: :account
      get "hubs", as: :hubs
      put "update", as: :update

      resources :addresses, controller: :user_addresses, only: %i[index create update destroy]
      post "addresses/:address_id/edit", to: "user_addresses#edit"
      get "gdpr/download", to: "users#download_gdpr"
      post "opt_out/:target", to: "users#opt_out"
    end

    namespace :itineraries do
      resource :last_available_date, only: :show
    end

    post "notes/fetch", to: "notes#index"
    get "search/shipments/:target", to: "shipments#search_shipments"
    get "shipments/pages/delta_page_handler", to: "shipments#delta_page_handler"
    post "create_shipment", controller: "shipments/booking_process", action: "create_shipment"
    resources :shipments, only: %i[index show] do
      get "test_email"
      get "reuse_booking_data", as: :reuse_booking
      %w[choose_offer get_offers update_shipment request_shipment send_quotes].each do |action|
        post action, controller: "shipments/booking_process", action: action
      end
      get "view_more_schedules", controller: "shipments/booking_process", action: "view_more_schedules"
      post "quotations/download", controller: "shipments/booking_process", action: "download_quotations"
      post "shipment/download", controller: "shipments/booking_process", action: "download_shipment"
      get "refresh_quotes", controller: "shipments/booking_process", action: "refresh_quotes"
      patch "update_user", on: :member
    end

    resources :trucking_availability, only: [:index]
    resources :trucking_counterparts, only: [:index]
    resources :incoterms, only: [:index]
    resources :locations, only: [:index]
    resources :nexuses, only: [:index]
    resources :quotations, only: [:show]
    resources :max_dimensions, only: [:index]
    get "currencies/base/:currency", to: "currencies#currencies_for_base"
    get "countries", to: "countries#index"
    get "currencies/refresh/:currency", to: "currencies#refresh_for_base"
    resources :contacts, only: %i[index show create update]
    post "contacts/update_contact_address/:id", to: "contacts#update_contact_address"
    get "search/contacts", to: "contacts#search_contacts"
    get "contacts/validations/form", to: "contacts#is_valid"
    post "contacts/delete_contact_address/:id", to: "contacts#delete_contact_address"
    post "shipments/:shipment_id/upload/:type", to: "shipments#upload_document"
    get "/documents/download/:document_id",
      to: "documents#download_redirect", as: :document_download
    get "/documents/download_url/:document_id", to: "documents#download_url"
    get "/documents/delete/:document_id", to: "documents#delete", as: :document_delete
    post "/admin/documents/action/:id", to: "admin/shipments#document_action"
    delete "/admin/documents/:id", to: "admin/shipments#document_delete"
    get "/organizations/scope/refresh", to: "organizations#fetch_scope"
    get "/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading",
      controller: :pdfs, action: :bill_of_lading, as: :user_shipment_bill_of_lading
    get "organizations/:name", to: "organizations#get_tenant"

    get "quotations/download/:id", to: "quotations#download_pdf"
    get "currencies/get", to: "users#currencies"
    post "currencies/set", to: "users#set_currency"
    post "super_admins/new_demo" => "super_admins#new_demo_site"
    post "super_admins/upload_image" => "super_admins#upload_image"
    get "messaging/get" => "notifications#index"
    post "messaging/send" => "notifications#send_message"

    post "messaging/data" => "notifications#shipment_data"
    post "messaging/shipments" => "notifications#shipments_data"
    post "messaging/mark" => "notifications#mark_as_read"
    get "content/component/:component" => "contents#component"
    get "booking_process/contacts", to: "contacts#booking_process"
  end
end

# D, [2020-07-17T16:17:11.103755 #16245] DEBUG -- : using default configuration
#                                                       Prefix Verb   URI Pattern                                                                                        Controller#Action
#                                                          idp        /                                                                                                  IDP::Engine
#                                               google_sign_in        /google_sign_in                                                                                    GoogleSignIn::Engine
#                                                      easymon        /up                                                                                                Easymon::Engine
#                                                      healthz GET    /healthz(.:format)                                                                                 application#health
#                                                          api        /                                                                                                  Api::Engine
#                                                    admiralty        /admiralty                                                                                         Admiralty::Engine
#                                                  sidekiq_web        /sidekiq                                                                                           Sidekiq::Web
#                                                     rswag_ui        /docs                                                                                              Rswag::Ui::Engine
#                                                    rswag_api        /docs                                                                                              Rswag::Api::Engine
#
#                                                    saml_init GET    /saml/init(.:format)                                                                               saml#init {:subdomain=>"api"}
#                                                saml_metadata GET    /saml/metadata(.:format)                                                                           saml#metadata {:subdomain=>"api"}
#                                                 saml_consume POST   /saml/consume(.:format)                                                                            saml#consume {:subdomain=>"api"}
#                             passwordless_authentication_user POST   /user/passwordless_authentication(.:format)                                                        users#passwordless_authentication
#                                                         user GET    /user(.:format)                                                                                    users#show
#                                                              POST   /user(.:format)                                                                                    users#create
#                                 organization_password_resets POST   /organizations/:organization_id/password_resets(.:format)                                          password_resets#create
#                             edit_organization_password_reset GET    /organizations/:organization_id/password_resets/:id/edit(.:format)                                 password_resets#edit
#                                  organization_password_reset PATCH  /organizations/:organization_id/password_resets/:id(.:format)                                      password_resets#update
#                                                              PUT    /organizations/:organization_id/password_resets/:id(.:format)                                      password_resets#update
#                                        current_organizations GET    /organizations/current(.:format)                                                                   organizations#current
#                    email_action_organization_admin_shipments GET    /organizations/:organization_id/admin/shipments/email_action(.:format)                             admin/shipments#email_action
#                                 organization_admin_shipments GET    /organizations/:organization_id/admin/shipments(.:format)                                          admin/shipments#index
#                                                              POST   /organizations/:organization_id/admin/shipments(.:format)                                          admin/shipments#create
#                                  organization_admin_shipment GET    /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#show
#                                                              PATCH  /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#update
#                                                              PUT    /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#update
#                                                              DELETE /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#destroy
#                              organization_admin_organization PATCH  /organizations/:organization_id/admin/organizations/:id(.:format)                                  admin/organizations#update
#                                                              PUT    /organizations/:organization_id/admin/organizations/:id(.:format)                                  admin/organizations#update
#                                   organization_admin_remarks GET    /organizations/:organization_id/admin/remarks(.:format)                                            admin/remarks#index
#                                                              POST   /organizations/:organization_id/admin/remarks(.:format)                                            admin/remarks#create
#                                    organization_admin_remark PATCH  /organizations/:organization_id/admin/remarks/:id(.:format)                                        admin/remarks#update
#                                                              PUT    /organizations/:organization_id/admin/remarks/:id(.:format)                                        admin/remarks#update
#                                                              DELETE /organizations/:organization_id/admin/remarks/:id(.:format)                                        admin/remarks#destroy
#        organization_admin_shipments_pages_delta_page_handler GET    /organizations/:organization_id/admin/shipments/pages/delta_page_handler(.:format)                 admin/shipments#delta_page_handler
#                                                              GET    /organizations/:organization_id/admin/search/shipments/:target(.:format)                           admin/shipments#search_shipments
#                            organization_admin_trucking_index GET    /organizations/:organization_id/admin/trucking(.:format)                                           admin/trucking#index
#                                                              POST   /organizations/:organization_id/admin/trucking(.:format)                                           admin/trucking#create
#                                  organization_admin_trucking GET    /organizations/:organization_id/admin/trucking/:id(.:format)                                       admin/trucking#show
#            organization_admin_trucking_trucking_zip_pricings POST   /organizations/:organization_id/admin/trucking/trucking_zip_pricings(.:format)                     admin/trucking#overwrite_zip_trucking
#           organization_admin_trucking_trucking_city_pricings POST   /organizations/:organization_id/admin/trucking/trucking_city_pricings(.:format)                    admin/trucking#overwrite_city_trucking
#                                                              POST   /organizations/:organization_id/admin/trucking/trucking_zip_pricings/:id(.:format)                 admin/trucking#overwrite_zip_trucking_by_hub
#                                                              POST   /organizations/:organization_id/admin/trucking/trucking_pricings/:id(.:format)                     admin/trucking#upload
#                                                              POST   /organizations/:organization_id/admin/trucking/trucking_city_pricings/:id(.:format)                admin/trucking#overwrite_city_trucking_by_hub
#                                                              POST   /organizations/:organization_id/admin/trucking/:id/edit(.:format)                                  admin/trucking#edit
#                            organization_admin_clients_agents POST   /organizations/:organization_id/admin/clients/agents(.:format)                                     admin/clients#agents
#                         organization_admin_trucking_download POST   /organizations/:organization_id/admin/trucking/download(.:format)                                  admin/trucking#download
#                    organization_admin_currencies_toggle_mode POST   /organizations/:organization_id/admin/currencies/toggle_mode(.:format)                             admin/currencies#toggle_mode
#                      organization_admin_currencies_set_rates POST   /organizations/:organization_id/admin/currencies/set_rates(.:format)                               admin/currencies#set_rates
#                            organization_admin_hub_set_status PATCH  /organizations/:organization_id/admin/hubs/:hub_id/set_status(.:format)                            admin/hubs#set_status
#                                      organization_admin_hubs GET    /organizations/:organization_id/admin/hubs(.:format)                                               admin/hubs#index
#                                                              POST   /organizations/:organization_id/admin/hubs(.:format)                                               admin/hubs#create
#                                       organization_admin_hub GET    /organizations/:organization_id/admin/hubs/:id(.:format)                                           admin/hubs#show
#                                                              PATCH  /organizations/:organization_id/admin/hubs/:id(.:format)                                           admin/hubs#update
#                                                              PUT    /organizations/:organization_id/admin/hubs/:id(.:format)                                           admin/hubs#update
#                        organization_admin_hubs_all_processed GET    /organizations/:organization_id/admin/hubs/all/processed(.:format)                                 admin/hubs#all_hubs
#                                                              POST   /organizations/:organization_id/admin/hubs/:id/update_mandatory_charges(.:format)                  admin/hubs#update_mandatory_charges
#                                                              POST   /organizations/:organization_id/admin/hubs/:hub_id/delete(.:format)                                admin/hubs#delete
#                                                              POST   /organizations/:organization_id/admin/hubs/:hub_id/image(.:format)                                 admin/hubs#update_image
#                            organization_admin_hubs_overwrite POST   /organizations/:organization_id/admin/hubs/process_csv(.:format)                                   admin/hubs#upload
#                       organization_admin_hubs_sheet_download GET    /organizations/:organization_id/admin/hubs/sheet/download(.:format)                                admin/hubs#download
#                       organization_admin_hubs_search_options GET    /organizations/:organization_id/admin/hubs/search/options(.:format)                                admin/hubs#options_search
#                      organization_admin_user_managers_assign POST   /organizations/:organization_id/admin/user_managers/assign(.:format)                               admin/user_managers#assign
#                               organization_admin_itineraries GET    /organizations/:organization_id/admin/itineraries(.:format)                                        admin/itineraries#index
#                                                              POST   /organizations/:organization_id/admin/itineraries(.:format)                                        admin/itineraries#create
#                                 organization_admin_itinerary GET    /organizations/:organization_id/admin/itineraries/:id(.:format)                                    admin/itineraries#show
#                                                              DELETE /organizations/:organization_id/admin/itineraries/:id(.:format)                                    admin/itineraries#destroy
#                              organization_admin_notes_upload POST   /organizations/:organization_id/admin/notes/upload(.:format)                                       admin/notes#upload
#                                                              POST   /organizations/:organization_id/admin/itineraries/:id/edit_notes(.:format)                         admin/itineraries#edit_notes
#                           upload_organization_admin_pricings POST   /organizations/:organization_id/admin/pricings/upload(.:format)                                    admin/pricings#upload
#                         download_organization_admin_pricings POST   /organizations/:organization_id/admin/pricings/download(.:format)                                  admin/pricings#download
#                                  organization_admin_pricings GET    /organizations/:organization_id/admin/pricings(.:format)                                           admin/pricings#index
#                                   organization_admin_pricing DELETE /organizations/:organization_id/admin/pricings/:id(.:format)                                       admin/pricings#destroy
#                            upload_organization_admin_margins POST   /organizations/:organization_id/admin/margins/upload(.:format)                                     admin/margins#upload
#                          download_organization_admin_margins POST   /organizations/:organization_id/admin/margins/download(.:format)                                   admin/margins#download
#                                   organization_admin_margins GET    /organizations/:organization_id/admin/margins(.:format)                                            admin/margins#index
#                                                              POST   /organizations/:organization_id/admin/margins(.:format)                                            admin/margins#create
#                                    organization_admin_margin GET    /organizations/:organization_id/admin/margins/:id(.:format)                                        admin/margins#show
#                                                              DELETE /organizations/:organization_id/admin/margins/:id(.:format)                                        admin/margins#destroy
#                                                              POST   /organizations/:organization_id/admin/companies/:id/edit_employees(.:format)                       admin/companies#edit_employees
#                               organization_admin_memberships GET    /organizations/:organization_id/admin/memberships(.:format)                                        admin/memberships#index
#                                                              POST   /organizations/:organization_id/admin/memberships(.:format)                                        admin/memberships#create
#                                organization_admin_membership GET    /organizations/:organization_id/admin/memberships/:id(.:format)                                    admin/memberships#show
#                                                              DELETE /organizations/:organization_id/admin/memberships/:id(.:format)                                    admin/memberships#destroy
#                         organization_admin_margins_form_data GET    /organizations/:organization_id/admin/margins/form/data(.:format)                                  admin/margins#form_data
#                         organization_admin_margins_test_data POST   /organizations/:organization_id/admin/margins/test/data(.:format)                                  admin/margins#test
#                  organization_admin_margins_form_itineraries GET    /organizations/:organization_id/admin/margins/form/itineraries(.:format)                           admin/margins#itinerary_list
#                     organization_admin_margins_form_fee_data GET    /organizations/:organization_id/admin/margins/form/fee_data(.:format)                              admin/margins#fee_data
#                   organization_admin_margins_update_multiple POST   /organizations/:organization_id/admin/margins/update/multiple(.:format)                            admin/margins#update_multiple
#                     organization_admin_memberships_bulk_edit POST   /organizations/:organization_id/admin/memberships/bulk_edit(.:format)                              admin/memberships#bulk_edit
#                      organization_admin_maps_editor_map_data GET    /organizations/:organization_id/admin/maps/editor_map_data(.:format)                               admin/maps#editor_map_data
#                             organization_admin_maps_geojsons GET    /organizations/:organization_id/admin/maps/geojsons(.:format)                                      admin/maps#geojsons
#                              organization_admin_maps_geojson GET    /organizations/:organization_id/admin/maps/geojson(.:format)                                       admin/maps#geojson
#                      organization_admin_maps_country_overlay POST   /organizations/:organization_id/admin/maps/country_overlay(.:format)                               admin/maps#country_overlay
#                                                              GET    /organizations/:organization_id/admin/client_pricings/:id(.:format)                                admin/pricings#client
#                                                              GET    /organizations/:organization_id/admin/route_pricings/:id(.:format)                                 admin/pricings#route
#                                                              GET    /organizations/:organization_id/admin/group_pricings/:id(.:format)                                 admin/pricings#group
#                                                              POST   /organizations/:organization_id/admin/pricings/update/:id(.:format)                                admin/pricings#update_price
#                                                              POST   /organizations/:organization_id/admin/pricings/test/:id(.:format)                                  admin/pricings#test
#          organization_admin_main_carriage_pricings_overwrite POST   /organizations/:organization_id/admin/pricings/train_and_ocean_pricings/process_csv(.:format)      admin/pricings#overwrite_main_carriage
#                                                              POST   /organizations/:organization_id/admin/pricings/update/:id(.:format)                                admin/pricings#update_price
#                                                              POST   /organizations/:organization_id/admin/pricings/:id/disable(.:format)                               admin/pricings#disable
#                 organization_admin_pricings_assign_dedicated POST   /organizations/:organization_id/admin/pricings/assign_dedicated(.:format)                          admin/pricings#assign_dedicated
#                     organization_admin_itineraries_overwrite POST   /organizations/:organization_id/admin/itineraries/process_csv(.:format)                            admin/itineraries#overwrite
#                                                              GET    /organizations/:organization_id/admin/itineraries/:id/layovers(.:format)                           admin/schedules#layovers
#                                                              GET    /organizations/:organization_id/admin/itineraries/:id/stops(.:format)                              admin/itineraries#stops
#                             organization_admin_vehicle_types GET    /organizations/:organization_id/admin/vehicle_types(.:format)                                      admin/vehicle_types#index
#                                   organization_admin_clients GET    /organizations/:organization_id/admin/clients(.:format)                                            admin/clients#index
#                                                              POST   /organizations/:organization_id/admin/clients(.:format)                                            admin/clients#create
#                                    organization_admin_client GET    /organizations/:organization_id/admin/clients/:id(.:format)                                        admin/clients#show
#                                                              DELETE /organizations/:organization_id/admin/clients/:id(.:format)                                        admin/clients#destroy
#                                 organization_admin_companies GET    /organizations/:organization_id/admin/companies(.:format)                                          admin/companies#index
#                                                              POST   /organizations/:organization_id/admin/companies(.:format)                                          admin/companies#create
#                                   organization_admin_company GET    /organizations/:organization_id/admin/companies/:id(.:format)                                      admin/companies#show
#                                                              DELETE /organizations/:organization_id/admin/companies/:id(.:format)                                      admin/companies#destroy
#                        edit_members_organization_admin_group POST   /organizations/:organization_id/admin/groups/:id/edit_members(.:format)                            admin/groups#edit_members
#                       with_margins_organization_admin_groups GET    /organizations/:organization_id/admin/groups/with_margins(.:format)                                admin/groups#with_margins
#                                    organization_admin_groups GET    /organizations/:organization_id/admin/groups(.:format)                                             admin/groups#index
#                                                              POST   /organizations/:organization_id/admin/groups(.:format)                                             admin/groups#create
#                                     organization_admin_group GET    /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#show
#                                                              PATCH  /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#update
#                                                              PUT    /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#update
#                                                              DELETE /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#destroy
#                             organization_admin_open_pricings GET    /organizations/:organization_id/admin/open_pricings(.:format)                                      admin/open_pricings#index
# organization_admin_open_main_lcl_carriage_pricings_overwrite POST   /organizations/:organization_id/admin/open_pricings/ocean_lcl_pricings/process_csv(.:format)       admin/open_pricings#overwrite_main_lcl_carriage
#                                                              POST   /organizations/:organization_id/admin/shipments/:shipment_id/upload/:type(.:format)                admin/shipments#upload_client_document
#                      upload_organization_admin_local_charges POST   /organizations/:organization_id/admin/local_charges/upload(.:format)                               admin/local_charges#upload
#                    download_organization_admin_local_charges POST   /organizations/:organization_id/admin/local_charges/download(.:format)                             admin/local_charges#download
#                       group_organization_admin_local_charges GET    /organizations/:organization_id/admin/local_charges/group(.:format)                                admin/local_charges#group
#                         edit_organization_admin_local_charge POST   /organizations/:organization_id/admin/local_charges/:id/edit(.:format)                             admin/local_charges#edit
#                             organization_admin_local_charges GET    /organizations/:organization_id/admin/local_charges(.:format)                                      admin/local_charges#index
#                              organization_admin_local_charge PATCH  /organizations/:organization_id/admin/local_charges/:id(.:format)                                  admin/local_charges#update
#                                                              PUT    /organizations/:organization_id/admin/local_charges/:id(.:format)                                  admin/local_charges#update
#                                                              DELETE /organizations/:organization_id/admin/local_charges/:id(.:format)                                  admin/local_charges#destroy
#                  upload_organization_admin_charge_categories POST   /organizations/:organization_id/admin/charge_categories/upload(.:format)                           admin/charge_categories#upload
#                download_organization_admin_charge_categories GET    /organizations/:organization_id/admin/charge_categories/download(.:format)                         admin/charge_categories#download
#                         organization_admin_charge_categories GET    /organizations/:organization_id/admin/charge_categories(.:format)                                  admin/charge_categories#index
#                           organization_admin_charge_category PATCH  /organizations/:organization_id/admin/charge_categories/:id(.:format)                              admin/charge_categories#update
#                                                              PUT    /organizations/:organization_id/admin/charge_categories/:id(.:format)                              admin/charge_categories#update
#                                                              GET    /organizations/:organization_id/admin/local_charges/:id/hub(.:format)                              admin/local_charges#hub_charges
#                                                              POST   /organizations/:organization_id/admin/customs_fees/:id/edit(.:format)                              admin/local_charges#edit_customs
#                                 organization_admin_discounts GET    /organizations/:organization_id/admin/discounts(.:format)                                          admin/discounts#index
#                organization_admin_discounts_user_itineraries GET    /organizations/:organization_id/admin/discounts/users/:user_id(.:format)                           admin/discounts#user_itineraries
#                 organization_admin_discounts_create_multiple POST   /organizations/:organization_id/admin/discounts/users/:user_id(.:format)                           admin/discounts#create_multiple
#                                                              POST   /organizations/:organization_id/admin/shipments/:id/edit_price(.:format)                           admin/shipments#edit_price
#                                                              POST   /organizations/:organization_id/admin/shipments/:id/edit_time(.:format)                            admin/shipments#edit_time
#                                                              POST   /organizations/:organization_id/admin/shipments/:id/edit_service_price(.:format)                   admin/shipments#edit_service_price
#                                 organization_admin_schedules GET    /organizations/:organization_id/admin/schedules(.:format)                                          admin/schedules#index
#                                  organization_admin_schedule GET    /organizations/:organization_id/admin/schedules/:id(.:format)                                      admin/schedules#show
#                                                              DELETE /organizations/:organization_id/admin/schedules/:id(.:format)                                      admin/schedules#destroy
#                          organization_admin_schedules_upload POST   /organizations/:organization_id/admin/schedules/upload(.:format)                                   admin/schedules#upload
#                        organization_admin_schedules_download POST   /organizations/:organization_id/admin/schedules/download(.:format)                                 admin/schedules#download_schedules
#                   organization_admin_schedules_auto_generate POST   /organizations/:organization_id/admin/schedules/auto_generate(.:format)                            admin/schedules#auto_generate_schedules
#             organization_admin_schedules_auto_generate_sheet POST   /organizations/:organization_id/admin/schedules/auto_generate_sheet(.:format)                      admin/schedules#generate_schedules_from_sheet
#                                                              GET    /organizations/:organization_id/admin/hubs(.:format)                                               admin/hubs#index
#                               organization_admin_search_hubs GET    /organizations/:organization_id/admin/search/hubs(.:format)                                        admin/hubs#search
#                           organization_admin_search_pricings GET    /organizations/:organization_id/admin/search/pricings(.:format)                                    admin/pricings#search
#                           organization_admin_search_contacts GET    /organizations/:organization_id/admin/search/contacts(.:format)                                    admin/contacts#search
#                                 organization_admin_dashboard GET    /organizations/:organization_id/admin/dashboard(.:format)                                          admin/dashboard#index
#                                   activate_organization_user GET    /organizations/:organization_id/users/:id/activate(.:format)                                       users#activate
#               passwordless_authentication_organization_users POST   /organizations/:organization_id/users/passwordless_authentication(.:format)                        users#passwordless_authentication
#                                       organization_user_home GET    /organizations/:organization_id/users/:user_id/home(.:format)                                      users#home
#                                       organization_user_show GET    /organizations/:organization_id/users/:user_id/show(.:format)                                      users#show
#                                    organization_user_account GET    /organizations/:organization_id/users/:user_id/account(.:format)                                   users#account
#                                       organization_user_hubs GET    /organizations/:organization_id/users/:user_id/hubs(.:format)                                      users#hubs
#                                     organization_user_update PUT    /organizations/:organization_id/users/:user_id/update(.:format)                                    users#update
#                             organization_user_toggle_sandbox GET    /organizations/:organization_id/users/:user_id/toggle_sandbox(.:format)                            users#toggle_sandbox
#                                  organization_user_addresses GET    /organizations/:organization_id/users/:user_id/addresses(.:format)                                 user_addresses#index
#                                                              POST   /organizations/:organization_id/users/:user_id/addresses(.:format)                                 user_addresses#create
#                                    organization_user_address PATCH  /organizations/:organization_id/users/:user_id/addresses/:id(.:format)                             user_addresses#update
#                                                              PUT    /organizations/:organization_id/users/:user_id/addresses/:id(.:format)                             user_addresses#update
#                                                              DELETE /organizations/:organization_id/users/:user_id/addresses/:id(.:format)                             user_addresses#destroy
#                                                              POST   /organizations/:organization_id/users/:user_id/addresses/:address_id/edit(.:format)                user_addresses#edit
#                              organization_user_gdpr_download GET    /organizations/:organization_id/users/:user_id/gdpr/download(.:format)                             users#download_gdpr
#                                                              POST   /organizations/:organization_id/users/:user_id/opt_out/:target(.:format)                           users#opt_out
#                                           organization_users GET    /organizations/:organization_id/users(.:format)                                                    users#index
#                                                              POST   /organizations/:organization_id/users(.:format)                                                    users#create
#                                            organization_user GET    /organizations/:organization_id/users/:id(.:format)                                                users#show
#                                                              PATCH  /organizations/:organization_id/users/:id(.:format)                                                users#update
#                                                              PUT    /organizations/:organization_id/users/:id(.:format)                                                users#update
#                                                              DELETE /organizations/:organization_id/users/:id(.:format)                                                users#destroy
#                 organization_itineraries_last_available_date GET    /organizations/:organization_id/itineraries/last_available_date(.:format)                          itineraries/last_available_dates#show
#                                     organization_notes_fetch POST   /organizations/:organization_id/notes/fetch(.:format)                                              notes#index
#                                                              GET    /organizations/:organization_id/search/shipments/:target(.:format)                                 shipments#search_shipments
#              organization_shipments_pages_delta_page_handler GET    /organizations/:organization_id/shipments/pages/delta_page_handler(.:format)                       shipments#delta_page_handler
#                                 organization_create_shipment POST   /organizations/:organization_id/create_shipment(.:format)                                          shipments/booking_process#create_shipment
#                             organization_shipment_test_email GET    /organizations/:organization_id/shipments/:shipment_id/test_email(.:format)                        shipments#test_email
#                          organization_shipment_reuse_booking GET    /organizations/:organization_id/shipments/:shipment_id/reuse_booking_data(.:format)                shipments#reuse_booking_data
#                           organization_shipment_choose_offer POST   /organizations/:organization_id/shipments/:shipment_id/choose_offer(.:format)                      shipments/booking_process#choose_offer
#                             organization_shipment_get_offers POST   /organizations/:organization_id/shipments/:shipment_id/get_offers(.:format)                        shipments/booking_process#get_offers
#                        organization_shipment_update_shipment POST   /organizations/:organization_id/shipments/:shipment_id/update_shipment(.:format)                   shipments/booking_process#update_shipment
#                       organization_shipment_request_shipment POST   /organizations/:organization_id/shipments/:shipment_id/request_shipment(.:format)                  shipments/booking_process#request_shipment
#                            organization_shipment_send_quotes POST   /organizations/:organization_id/shipments/:shipment_id/send_quotes(.:format)                       shipments/booking_process#send_quotes
#                    organization_shipment_view_more_schedules GET    /organizations/:organization_id/shipments/:shipment_id/view_more_schedules(.:format)               shipments/booking_process#view_more_schedules
#                    organization_shipment_quotations_download POST   /organizations/:organization_id/shipments/:shipment_id/quotations/download(.:format)               shipments/booking_process#download_quotations
#                      organization_shipment_shipment_download POST   /organizations/:organization_id/shipments/:shipment_id/shipment/download(.:format)                 shipments/booking_process#download_shipment
#                         organization_shipment_refresh_quotes GET    /organizations/:organization_id/shipments/:shipment_id/refresh_quotes(.:format)                    shipments/booking_process#refresh_quotes
#                            update_user_organization_shipment PATCH  /organizations/:organization_id/shipments/:id/update_user(.:format)                                shipments#update_user
#                                       organization_shipments GET    /organizations/:organization_id/shipments(.:format)                                                shipments#index
#                                        organization_shipment GET    /organizations/:organization_id/shipments/:id(.:format)                                            shipments#show
#                     organization_trucking_availability_index GET    /organizations/:organization_id/trucking_availability(.:format)                                    trucking_availability#index
#                           organization_trucking_counterparts GET    /organizations/:organization_id/trucking_counterparts(.:format)                                    trucking_counterparts#index
#                                       organization_incoterms GET    /organizations/:organization_id/incoterms(.:format)                                                incoterms#index
#                                       organization_locations GET    /organizations/:organization_id/locations(.:format)                                                locations#index
#                                         organization_nexuses GET    /organizations/:organization_id/nexuses(.:format)                                                  nexuses#index
#                                       organization_quotation GET    /organizations/:organization_id/quotations/:id(.:format)                                           quotations#show
#                                  organization_max_dimensions GET    /organizations/:organization_id/max_dimensions(.:format)                                           max_dimensions#index
#                                                              GET    /organizations/:organization_id/currencies/base/:currency(.:format)                                currencies#currencies_for_base
#                                       organization_countries GET    /organizations/:organization_id/countries(.:format)                                                countries#index
#                                                              GET    /organizations/:organization_id/currencies/refresh/:currency(.:format)                             currencies#refresh_for_base
#                                        organization_contacts GET    /organizations/:organization_id/contacts(.:format)                                                 contacts#index
#                                                              POST   /organizations/:organization_id/contacts(.:format)                                                 contacts#create
#                                         organization_contact GET    /organizations/:organization_id/contacts/:id(.:format)                                             contacts#show
#                                                              PATCH  /organizations/:organization_id/contacts/:id(.:format)                                             contacts#update
#                                                              PUT    /organizations/:organization_id/contacts/:id(.:format)                                             contacts#update
#                                                              POST   /organizations/:organization_id/contacts/update_contact_address/:id(.:format)                      contacts#update_contact_address
#                                 organization_search_contacts GET    /organizations/:organization_id/search/contacts(.:format)                                          contacts#search_contacts
#                       organization_contacts_validations_form GET    /organizations/:organization_id/contacts/validations/form(.:format)                                contacts#is_valid
#                                                              POST   /organizations/:organization_id/contacts/delete_contact_address/:id(.:format)                      contacts#delete_contact_address
#                                                              POST   /organizations/:organization_id/shipments/:shipment_id/upload/:type(.:format)                      shipments#upload_document
#                               organization_document_download GET    /organizations/:organization_id/documents/download/:document_id(.:format)                          documents#download_redirect
#                                                              GET    /organizations/:organization_id/documents/download_url/:document_id(.:format)                      documents#download_url
#                                 organization_document_delete GET    /organizations/:organization_id/documents/delete/:document_id(.:format)                            documents#delete
#                                                              POST   /organizations/:organization_id/admin/documents/action/:id(.:format)                               admin/shipments#document_action
#                                                              DELETE /organizations/:organization_id/admin/documents/:id(.:format)                                      admin/shipments#document_delete
#                     organization_organizations_scope_refresh GET    /organizations/:organization_id/organizations/scope/refresh(.:format)                              organizations#fetch_scope
#                    organization_user_shipment_bill_of_lading GET    /organizations/:organization_id/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading(.:format) pdfs#bill_of_lading
#                                                              GET    /organizations/:organization_id/organizations/:name(.:format)                                      organizations#get_tenant
#                                                              GET    /organizations/:organization_id/quotations/download/:id(.:format)                                  quotations#download_pdf
#                                  organization_currencies_get GET    /organizations/:organization_id/currencies/get(.:format)                                           users#currencies
#                                  organization_currencies_set POST   /organizations/:organization_id/currencies/set(.:format)                                           users#set_currency
#                           organization_super_admins_new_demo POST   /organizations/:organization_id/super_admins/new_demo(.:format)                                    super_admins#new_demo_site
#                       organization_super_admins_upload_image POST   /organizations/:organization_id/super_admins/upload_image(.:format)                                super_admins#upload_image
#                                   organization_messaging_get GET    /organizations/:organization_id/messaging/get(.:format)                                            notifications#index
#                                  organization_messaging_send POST   /organizations/:organization_id/messaging/send(.:format)                                           notifications#send_message
#                                  organization_messaging_data POST   /organizations/:organization_id/messaging/data(.:format)                                           notifications#shipment_data
#                             organization_messaging_shipments POST   /organizations/:organization_id/messaging/shipments(.:format)                                      notifications#shipments_data
#                                  organization_messaging_mark POST   /organizations/:organization_id/messaging/mark(.:format)                                           notifications#mark_as_read
#                                                              GET    /organizations/:organization_id/content/component/:component(.:format)                             contents#component
#                        organization_booking_process_contacts GET    /organizations/:organization_id/booking_process/contacts(.:format)                                 contacts#booking_process
#                                                organizations GET    /organizations(.:format)                                                                           organizations#index
#                                                 organization GET    /organizations/:id(.:format)                                                                       organizations#show
#                                           rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                         active_storage/blobs#show
#                                    rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)           active_storage/representations#show
#                                           rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                        active_storage/disk#show
#                                    update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                                active_storage/disk#update
#                                         rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                     active_storage/direct_uploads#create
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
# Routes for Api::Engine:
#                                    api_auth        /                                                                                        ApiAuth::Engine
#                                       v1_me GET    /v1/me(.:format)                                                                         api/v1/users#show
#                       scope_v1_organization GET    /v1/organizations/:id/scope(.:format)                                                    api/v1/organizations#scope
#                   countries_v1_organization GET    /v1/organizations/:id/countries(.:format)                                                api/v1/organizations#countries
#                   v1_organization_dashboard GET    /v1/organizations/:organization_id/dashboard(.:format)                                   api/v1/dashboard#show
#          v1_organization_quotation_download POST   /v1/organizations/:organization_id/quotations/:quotation_id/download(.:format)           api/v1/quotations#download
#            v1_organization_quotation_charge GET    /v1/organizations/:organization_id/quotations/:quotation_id/charges/:id(.:format)        api/v1/charges#show
#          v1_organization_quotation_schedule GET    /v1/organizations/:organization_id/quotations/:quotation_id/schedules/:id(.:format)      api/v1/schedules#show
#                  v1_organization_quotations GET    /v1/organizations/:organization_id/quotations(.:format)                                  api/v1/quotations#index
#                                             POST   /v1/organizations/:organization_id/quotations(.:format)                                  api/v1/quotations#create
#                   v1_organization_quotation GET    /v1/organizations/:organization_id/quotations/:id(.:format)                              api/v1/quotations#show
#                      v1_organization_tender PATCH  /v1/organizations/:organization_id/tenders/:id(.:format)                                 api/v1/tenders#update
#                                             PUT    /v1/organizations/:organization_id/tenders/:id(.:format)                                 api/v1/tenders#update
#            v1_organization_cargo_item_types GET    /v1/organizations/:organization_id/cargo_item_types(.:format)                            api/v1/cargo_item_types#index
#     v1_organization_trucking_availabilities GET    /v1/organizations/:organization_id/trucking_availabilities(.:format)                     api/v1/trucking_availabilities#index
#       v1_organization_trucking_counterparts GET    /v1/organizations/:organization_id/trucking_counterparts(.:format)                       api/v1/trucking_counterparts#index
#       v1_organization_trucking_capabilities GET    /v1/organizations/:organization_id/trucking_capabilities(.:format)                       api/v1/trucking_capabilities#index
#          v1_organization_trucking_countries GET    /v1/organizations/:organization_id/trucking_countries(.:format)                          api/v1/trucking_countries#index
#                      v1_organization_groups GET    /v1/organizations/:organization_id/groups(.:format)                                      api/v1/organizations_groups#index
#           origins_v1_organization_locations GET    /v1/organizations/:organization_id/locations/origins(.:format)                           api/v1/locations#origins
#      destinations_v1_organization_locations GET    /v1/organizations/:organization_id/locations/destinations(.:format)                      api/v1/locations#destinations
#                   v1_organization_locations GET    /v1/organizations/:organization_id/locations(.:format)                                   api/v1/locations#index
#                                             POST   /v1/organizations/:organization_id/locations(.:format)                                   api/v1/locations#create
#                    v1_organization_location GET    /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#show
#                                             PATCH  /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#update
#                                             PUT    /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#update
#                                             DELETE /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#destroy
#                  v1_organization_ahoy_index GET    /v1/organizations/:organization_id/ahoy(.:format)                                        api/v1/ahoy#index
#       password_reset_v1_organization_client PATCH  /v1/organizations/:organization_id/clients/:id/password_reset(.:format)                  api/v1/clients#password_reset
#                     v1_organization_clients GET    /v1/organizations/:organization_id/clients(.:format)                                     api/v1/clients#index
#                                             POST   /v1/organizations/:organization_id/clients(.:format)                                     api/v1/clients#create
#                      v1_organization_client GET    /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#show
#                                             PATCH  /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#update
#                                             PUT    /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#update
#                                             DELETE /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#destroy
#                  v1_organization_equipments GET    /v1/organizations/:organization_id/equipments(.:format)                                  api/v1/equipments#index
#                                             GET    /v1/organizations/:organization_id/dashboard(.:format)                                   api/v1/dashboard#show
#                                             POST   /v1/organizations/:organization_id/quotations/:quotation_id/download(.:format)           api/v1/quotations#download
#                                             GET    /v1/organizations/:organization_id/quotations/:quotation_id/charges/:id(.:format)        api/v1/charges#show
#                                             GET    /v1/organizations/:organization_id/quotations/:quotation_id/schedules/:id(.:format)      api/v1/schedules#show
#                                             POST   /v1/organizations/:organization_id/quotations(.:format)                                  api/v1/quotations#create
#                                             GET    /v1/organizations/:organization_id/quotations/:id(.:format)                              api/v1/quotations#show
#                                             PATCH  /v1/organizations/:organization_id/tenders/:id(.:format)                                 api/v1/tenders#update
#                                             PUT    /v1/organizations/:organization_id/tenders/:id(.:format)                                 api/v1/tenders#update
#                                             GET    /v1/organizations/:organization_id/cargo_item_types(.:format)                            api/v1/cargo_item_types#index
#                                             GET    /v1/organizations/:organization_id/groups(.:format)                                      api/v1/organizations_groups#index
#                                             GET    /v1/organizations/:organization_id/locations/origins(.:format)                           api/v1/locations#origins
#                                             GET    /v1/organizations/:organization_id/locations/destinations(.:format)                      api/v1/locations#destinations
#                                             GET    /v1/organizations/:organization_id/locations(.:format)                                   api/v1/locations#index
#                                             POST   /v1/organizations/:organization_id/locations(.:format)                                   api/v1/locations#create
#                                             GET    /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#show
#                                             PATCH  /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#update
#                                             PUT    /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#update
#                                             DELETE /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#destroy
#                  v1_organization_validation POST   /v1/organizations/:organization_id/validation(.:format)                                  api/v1/validations#create
#                       v1_organization_ports GET    /v1/organizations/:organization_id/ports(.:format)                                       api/v1/ports#index
# enabled_v1_organization_itinerary_schedules GET    /v1/organizations/:organization_id/itineraries/:itinerary_id/schedules/enabled(.:format) api/v1/schedules#enabled
#         v1_organization_itinerary_schedules GET    /v1/organizations/:organization_id/itineraries/:itinerary_id/schedules(.:format)         api/v1/schedules#index
#                 v1_organization_itineraries GET    /v1/organizations/:organization_id/itineraries(.:format)                                 api/v1/itineraries#index
#                            v1_organizations GET    /v1/organizations(.:format)                                                              api/v1/organizations#index
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
#     organizations GET   /organizations(.:format)          admiralty_tenants/organizations#index
#                   POST  /organizations(.:format)          admiralty_tenants/organizations#create
#  new_organization GET   /organizations/new(.:format)      admiralty_tenants/organizations#new
# edit_organization GET   /organizations/:id/edit(.:format) admiralty_tenants/organizations#edit
#      organization GET   /organizations/:id(.:format)      admiralty_tenants/organizations#show
#                   PATCH /organizations/:id(.:format)      admiralty_tenants/organizations#update
#                   PUT   /organizations/:id(.:format)      admiralty_tenants/organizations#update
#
# Routes for Admiralty::Engine:
#    admiralty_auth      /           AdmiraltyAuth::Engine
# admiralty_reports      /           AdmiraltyReports::Engine
# admiralty_tenants      /           AdmiraltyTenants::Engine
#              root GET  /           admiralty/dashboard#index
#
# Routes for Rswag::Ui::Engine:
#
#
# Routes for Rswag::Api::Engine:

# == Route Map
#
#                                                       Prefix Verb   URI Pattern                                                                                        Controller#Action
#                                                          idp        /                                                                                                  IDP::Engine
#                                               google_sign_in        /google_sign_in                                                                                    GoogleSignIn::Engine
#                                                      trestle        /admin                                                                                             Trestle::Engine
#                                                    admiralty        /admiralty                                                                                         Admiralty::Engine
#                                                          api        /                                                                                                  Api::Engine
#                                                      easymon        /up                                                                                                Easymon::Engine
#                                                      healthz GET    /healthz(.:format)                                                                                 application#health
#                                                 ping_version GET    /ping/version(.:format)                                                                            #<Proc:0x00007ff4640e43f8@/Users/wbeamish/imc/imc-react-api/config/routes.rb:6>
#                                                    rswag_api        /specs                                                                                             Rswag::Api::Engine
#                                                      sidekiq GET    /sidekiq(.:format)                                                                                 redirect(301, /admin/sidekiq)
#                             passwordless_authentication_user POST   /user/passwordless_authentication(.:format)                                                        users#passwordless_authentication
#                                                         user GET    /user(.:format)                                                                                    users#show
#                                                              POST   /user(.:format)                                                                                    users#create
#                                 organization_password_resets POST   /organizations/:organization_id/password_resets(.:format)                                          password_resets#create
#                             edit_organization_password_reset GET    /organizations/:organization_id/password_resets/:id/edit(.:format)                                 password_resets#edit
#                                  organization_password_reset PATCH  /organizations/:organization_id/password_resets/:id(.:format)                                      password_resets#update
#                                                              PUT    /organizations/:organization_id/password_resets/:id(.:format)                                      password_resets#update
#                                        current_organizations GET    /organizations/current(.:format)                                                                   organizations#current
#                    email_action_organization_admin_shipments GET    /organizations/:organization_id/admin/shipments/email_action(.:format)                             admin/shipments#email_action
#                                 organization_admin_shipments GET    /organizations/:organization_id/admin/shipments(.:format)                                          admin/shipments#index
#                                                              POST   /organizations/:organization_id/admin/shipments(.:format)                                          admin/shipments#create
#                                  organization_admin_shipment GET    /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#show
#                                                              PATCH  /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#update
#                                                              PUT    /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#update
#                                                              DELETE /organizations/:organization_id/admin/shipments/:id(.:format)                                      admin/shipments#destroy
#                              organization_admin_organization PATCH  /organizations/:organization_id/admin/organizations/:id(.:format)                                  admin/organizations#update
#                                                              PUT    /organizations/:organization_id/admin/organizations/:id(.:format)                                  admin/organizations#update
#                                   organization_admin_remarks GET    /organizations/:organization_id/admin/remarks(.:format)                                            admin/remarks#index
#                                                              POST   /organizations/:organization_id/admin/remarks(.:format)                                            admin/remarks#create
#                                    organization_admin_remark PATCH  /organizations/:organization_id/admin/remarks/:id(.:format)                                        admin/remarks#update
#                                                              PUT    /organizations/:organization_id/admin/remarks/:id(.:format)                                        admin/remarks#update
#                                                              DELETE /organizations/:organization_id/admin/remarks/:id(.:format)                                        admin/remarks#destroy
#        organization_admin_shipments_pages_delta_page_handler GET    /organizations/:organization_id/admin/shipments/pages/delta_page_handler(.:format)                 admin/shipments#delta_page_handler
#                                                              GET    /organizations/:organization_id/admin/search/shipments/:target(.:format)                           admin/shipments#search_shipments
#                            organization_admin_trucking_index GET    /organizations/:organization_id/admin/trucking(.:format)                                           admin/trucking#index
#                                                              POST   /organizations/:organization_id/admin/trucking(.:format)                                           admin/trucking#create
#                                  organization_admin_trucking GET    /organizations/:organization_id/admin/trucking/:id(.:format)                                       admin/trucking#show
#            organization_admin_trucking_trucking_zip_pricings POST   /organizations/:organization_id/admin/trucking/trucking_zip_pricings(.:format)                     admin/trucking#overwrite_zip_trucking
#           organization_admin_trucking_trucking_city_pricings POST   /organizations/:organization_id/admin/trucking/trucking_city_pricings(.:format)                    admin/trucking#overwrite_city_trucking
#                                                              POST   /organizations/:organization_id/admin/trucking/trucking_zip_pricings/:id(.:format)                 admin/trucking#overwrite_zip_trucking_by_hub
#                                                              POST   /organizations/:organization_id/admin/trucking/trucking_pricings/:id(.:format)                     admin/trucking#upload
#                                                              POST   /organizations/:organization_id/admin/trucking/trucking_city_pricings/:id(.:format)                admin/trucking#overwrite_city_trucking_by_hub
#                                                              POST   /organizations/:organization_id/admin/trucking/:id/edit(.:format)                                  admin/trucking#edit
#                            organization_admin_clients_agents POST   /organizations/:organization_id/admin/clients/agents(.:format)                                     admin/clients#agents
#                         organization_admin_trucking_download POST   /organizations/:organization_id/admin/trucking/download(.:format)                                  admin/trucking#download
#                    organization_admin_currencies_toggle_mode POST   /organizations/:organization_id/admin/currencies/toggle_mode(.:format)                             admin/currencies#toggle_mode
#                      organization_admin_currencies_set_rates POST   /organizations/:organization_id/admin/currencies/set_rates(.:format)                               admin/currencies#set_rates
#                            organization_admin_hub_set_status PATCH  /organizations/:organization_id/admin/hubs/:hub_id/set_status(.:format)                            admin/hubs#set_status
#                                      organization_admin_hubs GET    /organizations/:organization_id/admin/hubs(.:format)                                               admin/hubs#index
#                                                              POST   /organizations/:organization_id/admin/hubs(.:format)                                               admin/hubs#create
#                                       organization_admin_hub GET    /organizations/:organization_id/admin/hubs/:id(.:format)                                           admin/hubs#show
#                                                              PATCH  /organizations/:organization_id/admin/hubs/:id(.:format)                                           admin/hubs#update
#                                                              PUT    /organizations/:organization_id/admin/hubs/:id(.:format)                                           admin/hubs#update
#                        organization_admin_hubs_all_processed GET    /organizations/:organization_id/admin/hubs/all/processed(.:format)                                 admin/hubs#all_hubs
#                                                              POST   /organizations/:organization_id/admin/hubs/:id/update_mandatory_charges(.:format)                  admin/hubs#update_mandatory_charges
#                                                              POST   /organizations/:organization_id/admin/hubs/:hub_id/delete(.:format)                                admin/hubs#delete
#                                                              POST   /organizations/:organization_id/admin/hubs/:hub_id/image(.:format)                                 admin/hubs#update_image
#                            organization_admin_hubs_overwrite POST   /organizations/:organization_id/admin/hubs/process_csv(.:format)                                   admin/hubs#upload
#                       organization_admin_hubs_sheet_download GET    /organizations/:organization_id/admin/hubs/sheet/download(.:format)                                admin/hubs#download
#                       organization_admin_hubs_search_options GET    /organizations/:organization_id/admin/hubs/search/options(.:format)                                admin/hubs#options_search
#                      organization_admin_user_managers_assign POST   /organizations/:organization_id/admin/user_managers/assign(.:format)                               admin/user_managers#assign
#                               organization_admin_itineraries GET    /organizations/:organization_id/admin/itineraries(.:format)                                        admin/itineraries#index
#                                                              POST   /organizations/:organization_id/admin/itineraries(.:format)                                        admin/itineraries#create
#                                 organization_admin_itinerary GET    /organizations/:organization_id/admin/itineraries/:id(.:format)                                    admin/itineraries#show
#                                                              DELETE /organizations/:organization_id/admin/itineraries/:id(.:format)                                    admin/itineraries#destroy
#                              organization_admin_notes_upload POST   /organizations/:organization_id/admin/notes/upload(.:format)                                       admin/notes#upload
#                                                              POST   /organizations/:organization_id/admin/itineraries/:id/edit_notes(.:format)                         admin/itineraries#edit_notes
#                           upload_organization_admin_pricings POST   /organizations/:organization_id/admin/pricings/upload(.:format)                                    admin/pricings#upload
#                         download_organization_admin_pricings POST   /organizations/:organization_id/admin/pricings/download(.:format)                                  admin/pricings#download
#                                  organization_admin_pricings GET    /organizations/:organization_id/admin/pricings(.:format)                                           admin/pricings#index
#                                   organization_admin_pricing DELETE /organizations/:organization_id/admin/pricings/:id(.:format)                                       admin/pricings#destroy
#                            upload_organization_admin_margins POST   /organizations/:organization_id/admin/margins/upload(.:format)                                     admin/margins#upload
#                          download_organization_admin_margins POST   /organizations/:organization_id/admin/margins/download(.:format)                                   admin/margins#download
#                                   organization_admin_margins GET    /organizations/:organization_id/admin/margins(.:format)                                            admin/margins#index
#                                                              POST   /organizations/:organization_id/admin/margins(.:format)                                            admin/margins#create
#                                    organization_admin_margin GET    /organizations/:organization_id/admin/margins/:id(.:format)                                        admin/margins#show
#                                                              DELETE /organizations/:organization_id/admin/margins/:id(.:format)                                        admin/margins#destroy
#                                                              POST   /organizations/:organization_id/admin/companies/:id/edit_employees(.:format)                       admin/companies#edit_employees
#                               organization_admin_memberships GET    /organizations/:organization_id/admin/memberships(.:format)                                        admin/memberships#index
#                                                              POST   /organizations/:organization_id/admin/memberships(.:format)                                        admin/memberships#create
#                                organization_admin_membership GET    /organizations/:organization_id/admin/memberships/:id(.:format)                                    admin/memberships#show
#                                                              DELETE /organizations/:organization_id/admin/memberships/:id(.:format)                                    admin/memberships#destroy
#                         organization_admin_margins_form_data GET    /organizations/:organization_id/admin/margins/form/data(.:format)                                  admin/margins#form_data
#                         organization_admin_margins_test_data POST   /organizations/:organization_id/admin/margins/test/data(.:format)                                  admin/margins#test
#                  organization_admin_margins_form_itineraries GET    /organizations/:organization_id/admin/margins/form/itineraries(.:format)                           admin/margins#itinerary_list
#                     organization_admin_margins_form_fee_data GET    /organizations/:organization_id/admin/margins/form/fee_data(.:format)                              admin/margins#fee_data
#                   organization_admin_margins_update_multiple POST   /organizations/:organization_id/admin/margins/update/multiple(.:format)                            admin/margins#update_multiple
#                     organization_admin_memberships_bulk_edit POST   /organizations/:organization_id/admin/memberships/bulk_edit(.:format)                              admin/memberships#bulk_edit
#                      organization_admin_maps_editor_map_data GET    /organizations/:organization_id/admin/maps/editor_map_data(.:format)                               admin/maps#editor_map_data
#                             organization_admin_maps_geojsons GET    /organizations/:organization_id/admin/maps/geojsons(.:format)                                      admin/maps#geojsons
#                              organization_admin_maps_geojson GET    /organizations/:organization_id/admin/maps/geojson(.:format)                                       admin/maps#geojson
#                      organization_admin_maps_country_overlay POST   /organizations/:organization_id/admin/maps/country_overlay(.:format)                               admin/maps#country_overlay
#                                                              GET    /organizations/:organization_id/admin/client_pricings/:id(.:format)                                admin/pricings#client
#                                                              GET    /organizations/:organization_id/admin/route_pricings/:id(.:format)                                 admin/pricings#route
#                                                              GET    /organizations/:organization_id/admin/group_pricings/:id(.:format)                                 admin/pricings#group
#                                                              POST   /organizations/:organization_id/admin/pricings/update/:id(.:format)                                admin/pricings#update_price
#                                                              POST   /organizations/:organization_id/admin/pricings/test/:id(.:format)                                  admin/pricings#test
#          organization_admin_main_carriage_pricings_overwrite POST   /organizations/:organization_id/admin/pricings/train_and_ocean_pricings/process_csv(.:format)      admin/pricings#overwrite_main_carriage
#                                                              POST   /organizations/:organization_id/admin/pricings/update/:id(.:format)                                admin/pricings#update_price
#                                                              POST   /organizations/:organization_id/admin/pricings/:id/disable(.:format)                               admin/pricings#disable
#                 organization_admin_pricings_assign_dedicated POST   /organizations/:organization_id/admin/pricings/assign_dedicated(.:format)                          admin/pricings#assign_dedicated
#                     organization_admin_itineraries_overwrite POST   /organizations/:organization_id/admin/itineraries/process_csv(.:format)                            admin/itineraries#overwrite
#                                                              GET    /organizations/:organization_id/admin/itineraries/:id/layovers(.:format)                           admin/schedules#layovers
#                                                              GET    /organizations/:organization_id/admin/itineraries/:id/stops(.:format)                              admin/itineraries#stops
#                             organization_admin_vehicle_types GET    /organizations/:organization_id/admin/vehicle_types(.:format)                                      admin/vehicle_types#index
#                                   organization_admin_clients GET    /organizations/:organization_id/admin/clients(.:format)                                            admin/clients#index
#                                                              POST   /organizations/:organization_id/admin/clients(.:format)                                            admin/clients#create
#                                    organization_admin_client GET    /organizations/:organization_id/admin/clients/:id(.:format)                                        admin/clients#show
#                                                              DELETE /organizations/:organization_id/admin/clients/:id(.:format)                                        admin/clients#destroy
#                                 organization_admin_companies GET    /organizations/:organization_id/admin/companies(.:format)                                          admin/companies#index
#                                                              POST   /organizations/:organization_id/admin/companies(.:format)                                          admin/companies#create
#                                   organization_admin_company GET    /organizations/:organization_id/admin/companies/:id(.:format)                                      admin/companies#show
#                                                              DELETE /organizations/:organization_id/admin/companies/:id(.:format)                                      admin/companies#destroy
#                        edit_members_organization_admin_group POST   /organizations/:organization_id/admin/groups/:id/edit_members(.:format)                            admin/groups#edit_members
#                       with_margins_organization_admin_groups GET    /organizations/:organization_id/admin/groups/with_margins(.:format)                                admin/groups#with_margins
#                                    organization_admin_groups GET    /organizations/:organization_id/admin/groups(.:format)                                             admin/groups#index
#                                                              POST   /organizations/:organization_id/admin/groups(.:format)                                             admin/groups#create
#                                     organization_admin_group GET    /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#show
#                                                              PATCH  /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#update
#                                                              PUT    /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#update
#                                                              DELETE /organizations/:organization_id/admin/groups/:id(.:format)                                         admin/groups#destroy
#                             organization_admin_open_pricings GET    /organizations/:organization_id/admin/open_pricings(.:format)                                      admin/open_pricings#index
# organization_admin_open_main_lcl_carriage_pricings_overwrite POST   /organizations/:organization_id/admin/open_pricings/ocean_lcl_pricings/process_csv(.:format)       admin/open_pricings#overwrite_main_lcl_carriage
#                                                              POST   /organizations/:organization_id/admin/shipments/:shipment_id/upload/:type(.:format)                admin/shipments#upload_client_document
#                      upload_organization_admin_local_charges POST   /organizations/:organization_id/admin/local_charges/upload(.:format)                               admin/local_charges#upload
#                    download_organization_admin_local_charges POST   /organizations/:organization_id/admin/local_charges/download(.:format)                             admin/local_charges#download
#                       group_organization_admin_local_charges GET    /organizations/:organization_id/admin/local_charges/group(.:format)                                admin/local_charges#group
#                         edit_organization_admin_local_charge POST   /organizations/:organization_id/admin/local_charges/:id/edit(.:format)                             admin/local_charges#edit
#                             organization_admin_local_charges GET    /organizations/:organization_id/admin/local_charges(.:format)                                      admin/local_charges#index
#                              organization_admin_local_charge PATCH  /organizations/:organization_id/admin/local_charges/:id(.:format)                                  admin/local_charges#update
#                                                              PUT    /organizations/:organization_id/admin/local_charges/:id(.:format)                                  admin/local_charges#update
#                                                              DELETE /organizations/:organization_id/admin/local_charges/:id(.:format)                                  admin/local_charges#destroy
#                  upload_organization_admin_charge_categories POST   /organizations/:organization_id/admin/charge_categories/upload(.:format)                           admin/charge_categories#upload
#                download_organization_admin_charge_categories GET    /organizations/:organization_id/admin/charge_categories/download(.:format)                         admin/charge_categories#download
#                         organization_admin_charge_categories GET    /organizations/:organization_id/admin/charge_categories(.:format)                                  admin/charge_categories#index
#                           organization_admin_charge_category PATCH  /organizations/:organization_id/admin/charge_categories/:id(.:format)                              admin/charge_categories#update
#                                                              PUT    /organizations/:organization_id/admin/charge_categories/:id(.:format)                              admin/charge_categories#update
#                                                              GET    /organizations/:organization_id/admin/local_charges/:id/hub(.:format)                              admin/local_charges#hub_charges
#                                                              POST   /organizations/:organization_id/admin/customs_fees/:id/edit(.:format)                              admin/local_charges#edit_customs
#                                 organization_admin_discounts GET    /organizations/:organization_id/admin/discounts(.:format)                                          admin/discounts#index
#                organization_admin_discounts_user_itineraries GET    /organizations/:organization_id/admin/discounts/users/:user_id(.:format)                           admin/discounts#user_itineraries
#                 organization_admin_discounts_create_multiple POST   /organizations/:organization_id/admin/discounts/users/:user_id(.:format)                           admin/discounts#create_multiple
#                                                              POST   /organizations/:organization_id/admin/shipments/:id/edit_price(.:format)                           admin/shipments#edit_price
#                                                              POST   /organizations/:organization_id/admin/shipments/:id/edit_time(.:format)                            admin/shipments#edit_time
#                                                              POST   /organizations/:organization_id/admin/shipments/:id/edit_service_price(.:format)                   admin/shipments#edit_service_price
#                                 organization_admin_schedules GET    /organizations/:organization_id/admin/schedules(.:format)                                          admin/schedules#index
#                                  organization_admin_schedule GET    /organizations/:organization_id/admin/schedules/:id(.:format)                                      admin/schedules#show
#                                                              DELETE /organizations/:organization_id/admin/schedules/:id(.:format)                                      admin/schedules#destroy
#                          organization_admin_schedules_upload POST   /organizations/:organization_id/admin/schedules/upload(.:format)                                   admin/schedules#upload
#                        organization_admin_schedules_download POST   /organizations/:organization_id/admin/schedules/download(.:format)                                 admin/schedules#download_schedules
#                   organization_admin_schedules_auto_generate POST   /organizations/:organization_id/admin/schedules/auto_generate(.:format)                            admin/schedules#auto_generate_schedules
#             organization_admin_schedules_auto_generate_sheet POST   /organizations/:organization_id/admin/schedules/auto_generate_sheet(.:format)                      admin/schedules#generate_schedules_from_sheet
#                                                              GET    /organizations/:organization_id/admin/hubs(.:format)                                               admin/hubs#index
#                               organization_admin_search_hubs GET    /organizations/:organization_id/admin/search/hubs(.:format)                                        admin/hubs#search
#                           organization_admin_search_pricings GET    /organizations/:organization_id/admin/search/pricings(.:format)                                    admin/pricings#search
#                           organization_admin_search_contacts GET    /organizations/:organization_id/admin/search/contacts(.:format)                                    admin/contacts#search
#                                 organization_admin_dashboard GET    /organizations/:organization_id/admin/dashboard(.:format)                                          admin/dashboard#index
#                                   activate_organization_user GET    /organizations/:organization_id/users/:id/activate(.:format)                                       users#activate
#               passwordless_authentication_organization_users POST   /organizations/:organization_id/users/passwordless_authentication(.:format)                        users#passwordless_authentication
#                                       organization_user_home GET    /organizations/:organization_id/users/:user_id/home(.:format)                                      users#home
#                                       organization_user_show GET    /organizations/:organization_id/users/:user_id/show(.:format)                                      users#show
#                                    organization_user_account GET    /organizations/:organization_id/users/:user_id/account(.:format)                                   users#account
#                                       organization_user_hubs GET    /organizations/:organization_id/users/:user_id/hubs(.:format)                                      users#hubs
#                                     organization_user_update PUT    /organizations/:organization_id/users/:user_id/update(.:format)                                    users#update
#                                  organization_user_addresses GET    /organizations/:organization_id/users/:user_id/addresses(.:format)                                 user_addresses#index
#                                                              POST   /organizations/:organization_id/users/:user_id/addresses(.:format)                                 user_addresses#create
#                                    organization_user_address PATCH  /organizations/:organization_id/users/:user_id/addresses/:id(.:format)                             user_addresses#update
#                                                              PUT    /organizations/:organization_id/users/:user_id/addresses/:id(.:format)                             user_addresses#update
#                                                              DELETE /organizations/:organization_id/users/:user_id/addresses/:id(.:format)                             user_addresses#destroy
#                                                              POST   /organizations/:organization_id/users/:user_id/addresses/:address_id/edit(.:format)                user_addresses#edit
#                              organization_user_gdpr_download GET    /organizations/:organization_id/users/:user_id/gdpr/download(.:format)                             users#download_gdpr
#                                                              POST   /organizations/:organization_id/users/:user_id/opt_out/:target(.:format)                           users#opt_out
#                                           organization_users GET    /organizations/:organization_id/users(.:format)                                                    users#index
#                                                              POST   /organizations/:organization_id/users(.:format)                                                    users#create
#                                            organization_user GET    /organizations/:organization_id/users/:id(.:format)                                                users#show
#                                                              PATCH  /organizations/:organization_id/users/:id(.:format)                                                users#update
#                                                              PUT    /organizations/:organization_id/users/:id(.:format)                                                users#update
#                                                              DELETE /organizations/:organization_id/users/:id(.:format)                                                users#destroy
#                 organization_itineraries_last_available_date GET    /organizations/:organization_id/itineraries/last_available_date(.:format)                          itineraries/last_available_dates#show
#                                     organization_notes_fetch POST   /organizations/:organization_id/notes/fetch(.:format)                                              notes#index
#                                                              GET    /organizations/:organization_id/search/shipments/:target(.:format)                                 shipments#search_shipments
#              organization_shipments_pages_delta_page_handler GET    /organizations/:organization_id/shipments/pages/delta_page_handler(.:format)                       shipments#delta_page_handler
#                                 organization_create_shipment POST   /organizations/:organization_id/create_shipment(.:format)                                          shipments/booking_process#create_shipment
#                             organization_shipment_test_email GET    /organizations/:organization_id/shipments/:shipment_id/test_email(.:format)                        shipments#test_email
#                          organization_shipment_reuse_booking GET    /organizations/:organization_id/shipments/:shipment_id/reuse_booking_data(.:format)                shipments#reuse_booking_data
#                           organization_shipment_choose_offer POST   /organizations/:organization_id/shipments/:shipment_id/choose_offer(.:format)                      shipments/booking_process#choose_offer
#                             organization_shipment_get_offers POST   /organizations/:organization_id/shipments/:shipment_id/get_offers(.:format)                        shipments/booking_process#get_offers
#                        organization_shipment_update_shipment POST   /organizations/:organization_id/shipments/:shipment_id/update_shipment(.:format)                   shipments/booking_process#update_shipment
#                       organization_shipment_request_shipment POST   /organizations/:organization_id/shipments/:shipment_id/request_shipment(.:format)                  shipments/booking_process#request_shipment
#                            organization_shipment_send_quotes POST   /organizations/:organization_id/shipments/:shipment_id/send_quotes(.:format)                       shipments/booking_process#send_quotes
#                    organization_shipment_view_more_schedules GET    /organizations/:organization_id/shipments/:shipment_id/view_more_schedules(.:format)               shipments/booking_process#view_more_schedules
#                    organization_shipment_quotations_download POST   /organizations/:organization_id/shipments/:shipment_id/quotations/download(.:format)               shipments/booking_process#download_quotations
#                      organization_shipment_shipment_download POST   /organizations/:organization_id/shipments/:shipment_id/shipment/download(.:format)                 shipments/booking_process#download_shipment
#                         organization_shipment_refresh_quotes GET    /organizations/:organization_id/shipments/:shipment_id/refresh_quotes(.:format)                    shipments/booking_process#refresh_quotes
#                            update_user_organization_shipment PATCH  /organizations/:organization_id/shipments/:id/update_user(.:format)                                shipments#update_user
#                                       organization_shipments GET    /organizations/:organization_id/shipments(.:format)                                                shipments#index
#                                        organization_shipment GET    /organizations/:organization_id/shipments/:id(.:format)                                            shipments#show
#                     organization_trucking_availability_index GET    /organizations/:organization_id/trucking_availability(.:format)                                    trucking_availability#index
#                           organization_trucking_counterparts GET    /organizations/:organization_id/trucking_counterparts(.:format)                                    trucking_counterparts#index
#                                       organization_incoterms GET    /organizations/:organization_id/incoterms(.:format)                                                incoterms#index
#                                       organization_locations GET    /organizations/:organization_id/locations(.:format)                                                locations#index
#                                         organization_nexuses GET    /organizations/:organization_id/nexuses(.:format)                                                  nexuses#index
#                                       organization_quotation GET    /organizations/:organization_id/quotations/:id(.:format)                                           quotations#show
#                                  organization_max_dimensions GET    /organizations/:organization_id/max_dimensions(.:format)                                           max_dimensions#index
#                                                              GET    /organizations/:organization_id/currencies/base/:currency(.:format)                                currencies#currencies_for_base
#                                       organization_countries GET    /organizations/:organization_id/countries(.:format)                                                countries#index
#                                                              GET    /organizations/:organization_id/currencies/refresh/:currency(.:format)                             currencies#refresh_for_base
#                                        organization_contacts GET    /organizations/:organization_id/contacts(.:format)                                                 contacts#index
#                                                              POST   /organizations/:organization_id/contacts(.:format)                                                 contacts#create
#                                         organization_contact GET    /organizations/:organization_id/contacts/:id(.:format)                                             contacts#show
#                                                              PATCH  /organizations/:organization_id/contacts/:id(.:format)                                             contacts#update
#                                                              PUT    /organizations/:organization_id/contacts/:id(.:format)                                             contacts#update
#                                                              POST   /organizations/:organization_id/contacts/update_contact_address/:id(.:format)                      contacts#update_contact_address
#                                 organization_search_contacts GET    /organizations/:organization_id/search/contacts(.:format)                                          contacts#search_contacts
#                       organization_contacts_validations_form GET    /organizations/:organization_id/contacts/validations/form(.:format)                                contacts#is_valid
#                                                              POST   /organizations/:organization_id/contacts/delete_contact_address/:id(.:format)                      contacts#delete_contact_address
#                                                              POST   /organizations/:organization_id/shipments/:shipment_id/upload/:type(.:format)                      shipments#upload_document
#                               organization_document_download GET    /organizations/:organization_id/documents/download/:document_id(.:format)                          documents#download_redirect
#                                                              GET    /organizations/:organization_id/documents/download_url/:document_id(.:format)                      documents#download_url
#                                 organization_document_delete GET    /organizations/:organization_id/documents/delete/:document_id(.:format)                            documents#delete
#                                                              POST   /organizations/:organization_id/admin/documents/action/:id(.:format)                               admin/shipments#document_action
#                                                              DELETE /organizations/:organization_id/admin/documents/:id(.:format)                                      admin/shipments#document_delete
#                     organization_organizations_scope_refresh GET    /organizations/:organization_id/organizations/scope/refresh(.:format)                              organizations#fetch_scope
#                    organization_user_shipment_bill_of_lading GET    /organizations/:organization_id/user/:user_id/shipments/:shipment_id/pdfs/bill_of_lading(.:format) pdfs#bill_of_lading
#                                                              GET    /organizations/:organization_id/organizations/:name(.:format)                                      organizations#get_tenant
#                                                              GET    /organizations/:organization_id/quotations/download/:id(.:format)                                  quotations#download_pdf
#                                  organization_currencies_get GET    /organizations/:organization_id/currencies/get(.:format)                                           users#currencies
#                                  organization_currencies_set POST   /organizations/:organization_id/currencies/set(.:format)                                           users#set_currency
#                           organization_super_admins_new_demo POST   /organizations/:organization_id/super_admins/new_demo(.:format)                                    super_admins#new_demo_site
#                       organization_super_admins_upload_image POST   /organizations/:organization_id/super_admins/upload_image(.:format)                                super_admins#upload_image
#                                   organization_messaging_get GET    /organizations/:organization_id/messaging/get(.:format)                                            notifications#index
#                                  organization_messaging_send POST   /organizations/:organization_id/messaging/send(.:format)                                           notifications#send_message
#                                  organization_messaging_data POST   /organizations/:organization_id/messaging/data(.:format)                                           notifications#shipment_data
#                             organization_messaging_shipments POST   /organizations/:organization_id/messaging/shipments(.:format)                                      notifications#shipments_data
#                                  organization_messaging_mark POST   /organizations/:organization_id/messaging/mark(.:format)                                           notifications#mark_as_read
#                                                              GET    /organizations/:organization_id/content/component/:component(.:format)                             contents#component
#                        organization_booking_process_contacts GET    /organizations/:organization_id/booking_process/contacts(.:format)                                 contacts#booking_process
#                                                organizations GET    /organizations(.:format)                                                                           organizations#index
#                                                 organization GET    /organizations/:id(.:format)                                                                       organizations#show
#                                           rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                         active_storage/blobs#show
#                                    rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)           active_storage/representations#show
#                                           rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                        active_storage/disk#show
#                                    update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                                active_storage/disk#update
#                                         rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                     active_storage/direct_uploads#create
#
# Routes for IDP::Engine:
#     init_saml GET  /saml/:id/init(.:format)     idp/saml#init {:subdomain=>"idp"}
# metadata_saml GET  /saml/:id/metadata(.:format) idp/saml#metadata {:subdomain=>"idp"}
#  consume_saml POST /saml/:id/consume(.:format)  idp/saml#consume {:subdomain=>"idp"}
#
# Routes for GoogleSignIn::Engine:
# authorization POST /authorization(.:format) google_sign_in/authorizations#create
#      callback GET  /callback(.:format)      google_sign_in/callbacks#show
#
# Routes for Trestle::Engine:
#                                         new_admin GET    /admins/new(.:format)                         admins_admin/admin#new
#                                        edit_admin GET    /admins/:id/edit(.:format)                    admins_admin/admin#edit
#                                        new_client GET    /clients/new(.:format)                        clients_admin/admin#new
#                                       edit_client GET    /clients/:id/edit(.:format)                   clients_admin/admin#edit
#                                       new_country GET    /countries/new(.:format)                      countries_admin/admin#new
#                                      edit_country GET    /countries/:id/edit(.:format)                 countries_admin/admin#edit
#                               new_charge_category GET    /charge_categories/new(.:format)              charge_categories_admin/admin#new
#                              edit_charge_category GET    /charge_categories/:id/edit(.:format)         charge_categories_admin/admin#edit
#                                        new_domain GET    /domains/new(.:format)                        domains_admin/admin#new
#                                       edit_domain GET    /domains/:id/edit(.:format)                   domains_admin/admin#edit
#                         new_max_dimensions_bundle GET    /max_dimensions_bundles/new(.:format)         max_dimensions_bundles_admin/admin#new
#                        edit_max_dimensions_bundle GET    /max_dimensions_bundles/:id/edit(.:format)    max_dimensions_bundles_admin/admin#edit
#                                        new_margin GET    /margins/new(.:format)                        margins_admin/admin#new
#                                       edit_margin GET    /margins/:id/edit(.:format)                   margins_admin/admin#edit
#                                    new_membership GET    /memberships/new(.:format)                    memberships_admin/admin#new
#                                   edit_membership GET    /memberships/:id/edit(.:format)               memberships_admin/admin#edit
#                                  new_organization GET    /organizations/new(.:format)                  organizations_admin/admin#new
#                                 edit_organization GET    /organizations/:id/edit(.:format)             organizations_admin/admin#edit
#                                         new_query GET    /queries/new(.:format)                        queries_admin/admin#new
#                                        edit_query GET    /queries/:id/edit(.:format)                   queries_admin/admin#edit
#                                  new_subscription GET    /subscriptions/new(.:format)                  subscriptions_admin/admin#new
#                                 edit_subscription GET    /subscriptions/:id/edit(.:format)             subscriptions_admin/admin#edit
#                                         new_theme GET    /themes/new(.:format)                         themes_admin/admin#new
#                                        edit_theme GET    /themes/:id/edit(.:format)                    themes_admin/admin#edit
#                        new_tenant_cargo_item_type GET    /tenant_cargo_item_types/new(.:format)        tenant_cargo_item_types_admin/admin#new
#                       edit_tenant_cargo_item_type GET    /tenant_cargo_item_types/:id/edit(.:format)   tenant_cargo_item_types_admin/admin#edit
#                                            signin GET    /signin(.:format)                             trestle/auth/sessions#create
#                                       sidekiq_web        /sidekiq/web                                  Sidekiq::Web
#                                                   GET    /sidekiq/web(.:format)                        redirect(302, login)
#                      ruby_event_store_browser_app        /rails_event_store                            RubyEventStore::Browser::App
#                                 rails_event_store GET    /rails_event_store(.:format)                  redirect(302, login)
#                                             login GET    /login(.:format)                              trestle/auth/sessions#new
#                                                   POST   /login(.:format)                              trestle/auth/sessions#create
#                                            logout GET    /logout(.:format)                             trestle/auth/sessions#destroy
#                                admins_admin_index GET    /admins(.:format)                             admins_admin/admin#index
#                                                   POST   /admins(.:format)                             admins_admin/admin#create
#                                      admins_admin GET    /admins/:id(.:format)                         admins_admin/admin#show
#                                                   PATCH  /admins/:id(.:format)                         admins_admin/admin#update
#                                                   PUT    /admins/:id(.:format)                         admins_admin/admin#update
#                                                   DELETE /admins/:id(.:format)                         admins_admin/admin#destroy
#                     charge_categories_admin_index GET    /charge_categories(.:format)                  charge_categories_admin/admin#index
#                                                   POST   /charge_categories(.:format)                  charge_categories_admin/admin#create
#                           charge_categories_admin GET    /charge_categories/:id(.:format)              charge_categories_admin/admin#show
#                                                   PATCH  /charge_categories/:id(.:format)              charge_categories_admin/admin#update
#                                                   PUT    /charge_categories/:id(.:format)              charge_categories_admin/admin#update
#                                                   DELETE /charge_categories/:id(.:format)              charge_categories_admin/admin#destroy
#                               clients_admin_index GET    /clients(.:format)                            clients_admin/admin#index
#                                                   POST   /clients(.:format)                            clients_admin/admin#create
#                                     clients_admin GET    /clients/:id(.:format)                        clients_admin/admin#show
#                                                   PATCH  /clients/:id(.:format)                        clients_admin/admin#update
#                                                   PUT    /clients/:id(.:format)                        clients_admin/admin#update
#                                                   DELETE /clients/:id(.:format)                        clients_admin/admin#destroy
#              update_from_data_hub_countries_admin POST   /countries/:id/update_from_data_hub(.:format) countries_admin/admin#update_from_data_hub
#                             countries_admin_index GET    /countries(.:format)                          countries_admin/admin#index
#                                                   POST   /countries(.:format)                          countries_admin/admin#create
#                                   countries_admin GET    /countries/:id(.:format)                      countries_admin/admin#show
#                                                   PATCH  /countries/:id(.:format)                      countries_admin/admin#update
#                                                   PUT    /countries/:id(.:format)                      countries_admin/admin#update
#                                                   DELETE /countries/:id(.:format)                      countries_admin/admin#destroy
#                               domains_admin_index GET    /domains(.:format)                            domains_admin/admin#index
#                                                   POST   /domains(.:format)                            domains_admin/admin#create
#                                     domains_admin GET    /domains/:id(.:format)                        domains_admin/admin#show
#                                                   PATCH  /domains/:id(.:format)                        domains_admin/admin#update
#                                                   PUT    /domains/:id(.:format)                        domains_admin/admin#update
#                                                   DELETE /domains/:id(.:format)                        domains_admin/admin#destroy
#                               margins_admin_index GET    /margins(.:format)                            margins_admin/admin#index
#                                                   POST   /margins(.:format)                            margins_admin/admin#create
#                                     margins_admin GET    /margins/:id(.:format)                        margins_admin/admin#show
#                                                   PATCH  /margins/:id(.:format)                        margins_admin/admin#update
#                                                   PUT    /margins/:id(.:format)                        margins_admin/admin#update
#                                                   DELETE /margins/:id(.:format)                        margins_admin/admin#destroy
#                max_dimensions_bundles_admin_index GET    /max_dimensions_bundles(.:format)             max_dimensions_bundles_admin/admin#index
#                                                   POST   /max_dimensions_bundles(.:format)             max_dimensions_bundles_admin/admin#create
#                      max_dimensions_bundles_admin GET    /max_dimensions_bundles/:id(.:format)         max_dimensions_bundles_admin/admin#show
#                                                   PATCH  /max_dimensions_bundles/:id(.:format)         max_dimensions_bundles_admin/admin#update
#                                                   PUT    /max_dimensions_bundles/:id(.:format)         max_dimensions_bundles_admin/admin#update
#                                                   DELETE /max_dimensions_bundles/:id(.:format)         max_dimensions_bundles_admin/admin#destroy
#                           memberships_admin_index GET    /memberships(.:format)                        memberships_admin/admin#index
#                                                   POST   /memberships(.:format)                        memberships_admin/admin#create
#                                 memberships_admin GET    /memberships/:id(.:format)                    memberships_admin/admin#show
#                                                   PATCH  /memberships/:id(.:format)                    memberships_admin/admin#update
#                                                   PUT    /memberships/:id(.:format)                    memberships_admin/admin#update
#                                                   DELETE /memberships/:id(.:format)                    memberships_admin/admin#destroy
#                         organizations_admin_index GET    /organizations(.:format)                      organizations_admin/admin#index
#                                                   POST   /organizations(.:format)                      organizations_admin/admin#create
#                               organizations_admin GET    /organizations/:id(.:format)                  organizations_admin/admin#show
#                                                   PATCH  /organizations/:id(.:format)                  organizations_admin/admin#update
#                                                   PUT    /organizations/:id(.:format)                  organizations_admin/admin#update
#                            download_queries_admin GET    /queries/:id/download(.:format)               queries_admin/admin#download
#                               queries_admin_index GET    /queries(.:format)                            queries_admin/admin#index
#                                     queries_admin GET    /queries/:id(.:format)                        queries_admin/admin#show
#                         subscriptions_admin_index GET    /subscriptions(.:format)                      subscriptions_admin/admin#index
#                                                   POST   /subscriptions(.:format)                      subscriptions_admin/admin#create
#                               subscriptions_admin GET    /subscriptions/:id(.:format)                  subscriptions_admin/admin#show
#                                                   PATCH  /subscriptions/:id(.:format)                  subscriptions_admin/admin#update
#                                                   PUT    /subscriptions/:id(.:format)                  subscriptions_admin/admin#update
#                                                   DELETE /subscriptions/:id(.:format)                  subscriptions_admin/admin#destroy
#               tenant_cargo_item_types_admin_index GET    /tenant_cargo_item_types(.:format)            tenant_cargo_item_types_admin/admin#index
#                                                   POST   /tenant_cargo_item_types(.:format)            tenant_cargo_item_types_admin/admin#create
#                     tenant_cargo_item_types_admin GET    /tenant_cargo_item_types/:id(.:format)        tenant_cargo_item_types_admin/admin#show
#                                                   PATCH  /tenant_cargo_item_types/:id(.:format)        tenant_cargo_item_types_admin/admin#update
#                                                   PUT    /tenant_cargo_item_types/:id(.:format)        tenant_cargo_item_types_admin/admin#update
#                                                   DELETE /tenant_cargo_item_types/:id(.:format)        tenant_cargo_item_types_admin/admin#destroy
#                                themes_admin_index GET    /themes(.:format)                             themes_admin/admin#index
#                                                   POST   /themes(.:format)                             themes_admin/admin#create
#                                      themes_admin GET    /themes/:id(.:format)                         themes_admin/admin#show
#                                                   PATCH  /themes/:id(.:format)                         themes_admin/admin#update
#                                                   PUT    /themes/:id(.:format)                         themes_admin/admin#update
#                                                   DELETE /themes/:id(.:format)                         themes_admin/admin#destroy
#                     trestle_sidekiq_sidekiq_admin GET    /sidekiq(.:format)                            trestle/sidekiq/sidekiq_admin/admin#index
# trestle_rails_event_store_rails_event_store_admin GET    /rails_event_store(.:format)                  trestle/rails_event_store/rails_event_store_admin/admin#index
#                                              root GET    /                                             trestle/dashboard#index
#
# Routes for Admiralty::Engine:
#   root GET  /           redirect(301, /admin)
#
# Routes for ApiAuth::Engine:
#      oauth_token POST   /oauth/token(.:format)      api_auth/tokens#create
#     oauth_revoke POST   /oauth/revoke(.:format)     api_auth/tokens#revoke
# oauth_introspect POST   /oauth/introspect(.:format) api_auth/tokens#introspect
# oauth_token_info GET    /oauth/token/info(.:format) api_auth/token_info#show
#    oauth_signout DELETE /oauth/signout(.:format)    api_auth/auth#destroy
#
# Routes for Api::Engine:
#                                    api_auth        /                                                                                        ApiAuth::Engine
#                              v1_me_settings GET    /v1/me/settings(.:format)                                                                api/v1/settings#show
#                                       v1_me GET    /v1/me(.:format)                                                                         api/v1/users#show
#                                  v1_uploads POST   /v1/uploads(.:format)                                                                    api/v1/uploads#create
#                             v1_organization GET    /v1/organization(.:format)                                                               api/v1/organizations#show
#                       scope_v1_organization GET    /v1/organizations/:id/scope(.:format)                                                    api/v1/organizations#scope
#                   countries_v1_organization GET    /v1/organizations/:id/countries(.:format)                                                api/v1/organizations#countries
#                   v1_organization_dashboard GET    /v1/organizations/:organization_id/dashboard(.:format)                                   api/v1/dashboard#show
#          v1_organization_quotation_download POST   /v1/organizations/:organization_id/quotations/:quotation_id/download(.:format)           api/v1/quotations#download
#            v1_organization_quotation_charge GET    /v1/organizations/:organization_id/quotations/:quotation_id/charges/:id(.:format)        api/v1/charges#show
#          v1_organization_quotation_schedule GET    /v1/organizations/:organization_id/quotations/:quotation_id/schedules/:id(.:format)      api/v1/schedules#show
#                  v1_organization_quotations GET    /v1/organizations/:organization_id/quotations(.:format)                                  api/v1/quotations#index
#                                             POST   /v1/organizations/:organization_id/quotations(.:format)                                  api/v1/quotations#create
#                   v1_organization_quotation GET    /v1/organizations/:organization_id/quotations/:id(.:format)                              api/v1/quotations#show
#                      v1_organization_tender PATCH  /v1/organizations/:organization_id/tenders/:id(.:format)                                 api/v1/tenders#update
#                                             PUT    /v1/organizations/:organization_id/tenders/:id(.:format)                                 api/v1/tenders#update
#            v1_organization_cargo_item_types GET    /v1/organizations/:organization_id/cargo_item_types(.:format)                            api/v1/cargo_item_types#index
#     v1_organization_trucking_availabilities GET    /v1/organizations/:organization_id/trucking_availabilities(.:format)                     api/v1/trucking_availabilities#index
#       v1_organization_trucking_counterparts GET    /v1/organizations/:organization_id/trucking_counterparts(.:format)                       api/v1/trucking_counterparts#index
#       v1_organization_trucking_capabilities GET    /v1/organizations/:organization_id/trucking_capabilities(.:format)                       api/v1/trucking_capabilities#index
#          v1_organization_trucking_countries GET    /v1/organizations/:organization_id/trucking_countries(.:format)                          api/v1/trucking_countries#index
#                      v1_organization_groups GET    /v1/organizations/:organization_id/groups(.:format)                                      api/v1/organizations_groups#index
#           origins_v1_organization_locations GET    /v1/organizations/:organization_id/locations/origins(.:format)                           api/v1/locations#origins
#      destinations_v1_organization_locations GET    /v1/organizations/:organization_id/locations/destinations(.:format)                      api/v1/locations#destinations
#                   v1_organization_locations GET    /v1/organizations/:organization_id/locations(.:format)                                   api/v1/locations#index
#                                             POST   /v1/organizations/:organization_id/locations(.:format)                                   api/v1/locations#create
#                    v1_organization_location GET    /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#show
#                                             PATCH  /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#update
#                                             PUT    /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#update
#                                             DELETE /v1/organizations/:organization_id/locations/:id(.:format)                               api/v1/locations#destroy
#                  v1_organization_ahoy_index GET    /v1/organizations/:organization_id/ahoy(.:format)                                        api/v1/ahoy#index
#       password_reset_v1_organization_client PATCH  /v1/organizations/:organization_id/clients/:id/password_reset(.:format)                  api/v1/clients#password_reset
#                     v1_organization_clients GET    /v1/organizations/:organization_id/clients(.:format)                                     api/v1/clients#index
#                                             POST   /v1/organizations/:organization_id/clients(.:format)                                     api/v1/clients#create
#                      v1_organization_client GET    /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#show
#                                             PATCH  /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#update
#                                             PUT    /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#update
#                                             DELETE /v1/organizations/:organization_id/clients/:id(.:format)                                 api/v1/clients#destroy
#                  v1_organization_equipments GET    /v1/organizations/:organization_id/equipments(.:format)                                  api/v1/equipments#index
#                  v1_organization_validation POST   /v1/organizations/:organization_id/validation(.:format)                                  api/v1/validations#create
#                       v1_organization_ports GET    /v1/organizations/:organization_id/ports(.:format)                                       api/v1/ports#index
# enabled_v1_organization_itinerary_schedules GET    /v1/organizations/:organization_id/itineraries/:itinerary_id/schedules/enabled(.:format) api/v1/schedules#enabled
#         v1_organization_itinerary_schedules GET    /v1/organizations/:organization_id/itineraries/:itinerary_id/schedules(.:format)         api/v1/schedules#index
#                 v1_organization_itineraries GET    /v1/organizations/:organization_id/itineraries(.:format)                                 api/v1/itineraries#index
#                            v1_organizations GET    /v1/organizations(.:format)                                                              api/v1/organizations#index
#            v2_organization_query_result_set GET    /v2/organizations/:organization_id/queries/:query_id/result_set(.:format)                api/v2/queries#result_set
#              v2_organization_query_requests POST   /v2/organizations/:organization_id/queries/:query_id/requests(.:format)                  api/v2/requests#create
#           v2_organization_query_cargo_units GET    /v2/organizations/:organization_id/queries/:query_id/cargo_units(.:format)               api/v2/cargo_units#index
#            v2_organization_query_cargo_unit GET    /v2/organizations/:organization_id/queries/:query_id/cargo_units/:id(.:format)           api/v2/cargo_units#show
#                     v2_organization_queries GET    /v2/organizations/:organization_id/queries(.:format)                                     api/v2/queries#index
#                                             POST   /v2/organizations/:organization_id/queries(.:format)                                     api/v2/queries#create
#                       v2_organization_query GET    /v2/organizations/:organization_id/queries/:id(.:format)                                 api/v2/queries#show
#          v2_organization_result_set_results GET    /v2/organizations/:organization_id/result_sets/:result_set_id/results(.:format)          api/v2/results#index
#           v2_organization_result_set_errors GET    /v2/organizations/:organization_id/result_sets/:result_set_id/errors(.:format)           api/v2/errors#index
#                  v2_organization_result_set GET    /v2/organizations/:organization_id/result_sets/:id(.:format)                             api/v2/result_sets#show
#              v2_organization_result_charges GET    /v2/organizations/:organization_id/results/:result_id/charges(.:format)                  api/v2/charges#index
#                      v2_organization_result GET    /v2/organizations/:organization_id/results/:id(.:format)                                 api/v2/results#show
#                 v2_organization_offer_email GET    /v2/organizations/:organization_id/offers/:offer_id/email(.:format)                      api/v2/offers#email
#                   v2_organization_offer_pdf GET    /v2/organizations/:organization_id/offers/:offer_id/pdf(.:format)                        api/v2/offers#pdf
#                  v2_organization_offer_xlsx GET    /v2/organizations/:organization_id/offers/:offer_id/xlsx(.:format)                       api/v2/offers#xlsx
#                      v2_organization_offers POST   /v2/organizations/:organization_id/offers(.:format)                                      api/v2/offers#create
#                     v2_organization_uploads POST   /v2/organizations/:organization_id/uploads(.:format)                                     api/v2/uploads#create
#                       v2_organization_theme GET    /v2/organizations/:organization_id/theme(.:format)                                       api/v2/themes#show
#                       v2_organization_scope GET    /v2/organizations/:organization_id/scope(.:format)                                       api/v2/scopes#show
#                     v2_organization_profile GET    /v2/organizations/:organization_id/profile(.:format)                                     api/v2/profiles#show
#                                             PATCH  /v2/organizations/:organization_id/profile(.:format)                                     api/v2/profiles#update
#                                             PUT    /v2/organizations/:organization_id/profile(.:format)                                     api/v2/profiles#update
#                            v2_organizations GET    /v2/organizations(.:format)                                                              api/v2/organizations#index
#
# Routes for Easymon::Engine:
#        GET  /(.:format)       easymon/checks#index
#   root GET  /                 easymon/checks#index
#        GET  /:check(.:format) easymon/checks#show
#
# Routes for Rswag::Api::Engine:
