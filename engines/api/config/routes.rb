# frozen_string_literal: true

Api::Engine.routes.draw do
  mount ApiAuth::Engine, at: "/"

  namespace :v1 do
    resource :me, controller: :users, only: :show do
      resource :settings, only: :show
    end

    resource :uploads, only: :create

    resource :organization, only: :show
    resources :organizations, only: :index do
      member do
        get "scope"
        get "countries"
      end

      resource :dashboard, controller: :dashboard, only: %i[show]
      resources :quotations, only: %i[create show index] do
        post :download
        resources :charges, only: %i[show]
        resources :schedules, only: %i[show]
      end

      resources :tenders, only: :update
      resources :cargo_item_types, only: :index
      resources :trucking_availabilities, only: :index
      resources :trucking_counterparts, only: :index
      resources :trucking_capabilities, only: :index
      resources :trucking_countries, only: :index
      resources :groups, controller: :organizations_groups, only: :index
      resources :locations do
        collection do
          get "origins"
          get "destinations"
        end
      end

      resources :ahoy, only: :index

      resources :clients, only: %i[index show update create destroy] do
        member do
          patch "password_reset"
        end
      end

      resources :equipments, only: :index
      resource :validation, only: [:create]
      resources :ports, only: %i[index]

      resources :itineraries, only: %i[index] do
        resources :schedules, only: :index do
          collection do
            get "enabled"
          end
        end
      end
      resources :companies, only: :update
    end
  end

  namespace :v2 do
    namespace :admin do
      resources :passwords, only: %i[create update]
    end
    resources :organizations, only: :index do
      namespace :admin do
        resources :companies, only: %i[create show update destroy] do
          resources :groups_memberships, only: %i[index create destroy]
        end
        resources :companies, only: :index do
          resources :clients, only: %i[index]
          resources :shipment_requests, only: %i[index]
          resources :queries, only: %i[index]
        end
        resources :groups, only: %i[index create update destroy]

        resources :users, only: %i[index create update destroy]
      end
    end
    resources :organizations, only: :index do
      resources :queries, only: %i[create show index update] do
        get "result_set"
        post "recalculate"
        resources :request_for_quotations, only: [:create]
        resources :cargo_units, only: %i[index show]
        resources :results, only: [:index]
        resources :errors, only: [:index]
      end
      resources :result_sets, only: [:show] do
        resources :results, only: [:index]
      end
      resources :results, only: [:show] do
        resources :charges, only: [:index]
        resources :route_sections, only: [:index]
        resources :schedules, only: %i[index show]
        resources :shipment_requests, only: %i[create]
      end
      resources :shipment_requests, only: %i[index show]
      resources :offers, only: [:create] do
        get "email"
        get "pdf"
        get "xlsx"
      end
      resource :validation, only: [:create]
      resources :uploads, only: [:create, :show]
      resource :theme, only: [:show]
      resource :scope, only: [:show]
      resource :colli_types, only: [:show]
      resource :profile, only: %i[show update]
      resources :carriers, only: %i[index show]
      resource :active_locodes, only: %i[show]
    end
    resources :users do
      get "validate", on: :collection
    end
    resources :countries, only: %i[index]
    resources :file_descriptors, only: %i[create]
    resources :passwords, only: %i[create update]
    resources :interactions, only: %i[index]
    resources :users_interactions, only: %i[index create]
  end
end
