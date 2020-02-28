# frozen_string_literal: true

AdmiraltyTenants::Engine.routes.draw do
  resources :tenants, only: %i[index show new create edit update]
end
