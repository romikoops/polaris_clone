# frozen_string_literal: true

AdmiraltyReports::Engine.routes.draw do
  resources :reports, only: %i(index show)
end
