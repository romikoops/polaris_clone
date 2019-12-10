# frozen_string_literal: true

AdmiraltyReports::Engine.routes.draw do
  resources :reports, only: %i(index show)
  resources :stats, only: [] do
    get 'download', on: :collection
  end
end
