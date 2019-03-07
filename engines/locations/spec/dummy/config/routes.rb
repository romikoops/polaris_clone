# frozen_string_literal: true

Rails.application.routes.draw do
  mount Locations::Engine => '/'
end
