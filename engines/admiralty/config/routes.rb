# frozen_string_literal: true

Trestle::Engine.routes.draw do
  resources :organizations, only: %i[new edit], module: "organizations_admin", controller: "admin"
  resources :themes, only: %i[new edit], module: "themes_admin", controller: "admin"

  controller "trestle/auth/sessions" do
    get "signin" => :create
  end
end

Admiralty::Engine.routes.draw do
  root to: redirect("/admin", status: 301)
end
