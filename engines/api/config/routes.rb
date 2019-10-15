# frozen_string_literal: true

Api::Engine.routes.draw do
  namespace :v1 do
    resource :me, controller: :users, only: :show
    resources :clients, only: %i(index show)
    resource :dashboard, controller: :dashboard, only: %i(show)
    resources :itineraries, only: :index
  end
end
