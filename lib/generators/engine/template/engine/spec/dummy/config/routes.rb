# frozen_string_literal: true

Rails.application.routes.draw do
  mount EngineTemplate::Engine => '/'
end
