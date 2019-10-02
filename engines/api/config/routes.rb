# frozen_string_literal: true

Api::Engine.routes.draw do
  namespace :v1 do
    resource :me, controller: :users, only: %i(show)
    resource :dashboard, controller: :dashboard, only: %i(show)
  end
end
