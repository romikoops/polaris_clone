# frozen_string_literal: true

Rails.application.routes.draw do
  mount ApiDocs::Engine => '/'
end
