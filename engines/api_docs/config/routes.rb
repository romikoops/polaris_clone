# frozen_string_literal: true

ApiDocs::Engine.routes.draw do
  mount Raddocs::App => '/docs'
end
