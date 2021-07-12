# frozen_string_literal: true

Trestle::Engine.routes.draw do
  resources :admins, only: %i[new edit], module: "admins_admin", controller: "admin"
  resources :clients, only: %i[new edit], module: "clients_admin", controller: "admin"
  resources :countries, only: %i[new edit], module: "countries_admin", controller: "admin"
  resources :charge_categories, only: %i[new edit], module: "charge_categories_admin", controller: "admin"
  resources :domains, only: %i[new edit], module: "domains_admin", controller: "admin"
  resources :max_dimensions_bundles, only: %i[new edit], module: "max_dimensions_bundles_admin", controller: "admin"
  resources :margins, only: %i[new edit], module: "margins_admin", controller: "admin"
  resources :memberships, only: %i[new edit], module: "memberships_admin", controller: "admin"
  resources :organizations, only: %i[new edit], module: "organizations_admin", controller: "admin"
  resources :queries, only: %i[new edit], module: "queries_admin", controller: "admin"
  resources :subscriptions, only: %i[new edit], module: "subscriptions_admin", controller: "admin"
  resources :themes, only: %i[new edit], module: "themes_admin", controller: "admin"
  resources :tenant_cargo_item_types, only: %i[new edit], module: "tenant_cargo_item_types_admin", controller: "admin"

  controller "trestle/auth/sessions" do
    get "signin" => :create
  end
end

Admiralty::Engine.routes.draw do
  root to: redirect("/admin", status: 301)
end
