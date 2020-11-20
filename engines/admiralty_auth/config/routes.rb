# frozen_string_literal: true

AdmiraltyAuth::Engine.routes.draw do
  get "login", to: "logins#new"
  get "login/create", to: "logins#create", as: :create_login
  delete "login", to: "logins#destroy", as: :delete_login
end
