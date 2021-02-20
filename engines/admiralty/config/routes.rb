# frozen_string_literal: true

Trestle::Engine.routes.draw do
  resources :clients, only: %i[new edit], module: "clients_admin", controller: "admin"
  resources :memberships, only: %i[new edit], module: "memberships_admin", controller: "admin"
  resources :organizations, only: %i[new edit], module: "organizations_admin", controller: "admin"
  resources :queries, only: %i[new edit], module: "queries_admin", controller: "admin"
  resources :subscriptions, only: %i[new edit], module: "subscriptions_admin", controller: "admin"
  resources :themes, only: %i[new edit], module: "themes_admin", controller: "admin"
  resources :users, only: %i[new edit], module: "users_admin", controller: "admin"

  controller "trestle/auth/sessions" do
    get "signin" => :create
  end
end

Admiralty::Engine.routes.draw do
  root to: redirect("/admin", status: 301)
end
