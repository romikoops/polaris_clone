# frozen_string_literal: true

Admiralty::Engine.routes.draw do
  mount AdmiraltyAuth::Engine, at: '/'
  mount AdmiraltyReports::Engine, at: '/'
  mount AdmiraltyTenants::Engine, at: '/'

  root to: 'dashboard#index'
end
