# frozen_string_literal: true

Rails.application.routes.draw do
  mount AdmiraltyAuth::Engine => '/'
  mount AdmiraltyTenants::Engine => '/'
end
