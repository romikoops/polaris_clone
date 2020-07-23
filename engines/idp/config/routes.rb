# frozen_string_literal: true

IDP::Engine.routes.draw do
  constraints subdomain: "idp" do
    resources :saml, only: [] do
      member do
        get :init
        get :metadata
        post :consume
      end
    end
  end
end
