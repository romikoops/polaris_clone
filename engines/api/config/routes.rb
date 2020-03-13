# frozen_string_literal: true

Api::Engine.routes.draw do
  mount ApiAuth::Engine, at: '/'

  namespace :v1 do
    resource :me, controller: :users, only: :show
    resources :clients, only: %i[index show create]
    resources :tenants, only: :index do
      member do
        get 'scope'
      end
    end
    resource :dashboard, controller: :dashboard, only: %i[show]
    resources :quotations do
      post :create
      post :download
      resources :charges, only: %i[show]
    end
    resources :cargo_item_types, only: :index
    resources :trucking_availability, controller: :trucking_availability, only: %i[index]
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

    resources :itineraries, only: %i[index] do
      collection do
        get 'ports/:tenant_uuid', action: :ports
      end
    end
  end

  mount ApiDocs::Engine, at: '/'
end
