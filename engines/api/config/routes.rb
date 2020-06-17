# frozen_string_literal: true

Api::Engine.routes.draw do
  mount ApiAuth::Engine, at: '/'

  namespace :v1 do
    resource :me, controller: :users, only: :show
    resources :clients, only: %i[index show create] do
      member do
        patch 'password_reset'
      end
    end
    resources :equipments, only: :index
    resources :tenants, only: :index do
      member do
        get 'scope'
        get 'countries'
      end
    end
    resource :dashboard, controller: :dashboard, only: %i[show]
    resources :quotations, only: %i[create show] do
      post :download
      resources :charges, only: %i[show]
      resources :schedules, only: %i[show]
    end
    resources :tenders, only: :update
    resources :cargo_item_types, only: :index
    resources :trucking_availabilities, only: :index
    resources :trucking_counterparts, only: :index
    resources :trucking_capabilities, only: [:index]
    resources :trucking_countries, only: [:index]
    resources :groups, controller: :tenants_groups, only: :index
    resources :locations do
      collection do
        get 'origins'
        get 'destinations'
      end
    end

    resources :ahoy, only: [] do
      member do
        get 'settings'
      end
    end

    resource :validation, only: [:create]

    resources :itineraries, only: %i[index] do
      collection do
        get 'ports/:tenant_uuid', action: :ports
      end

      resources :schedules, only: :index do
        collection do
          get 'enabled'
        end
      end
    end
  end
end
