# frozen_string_literal: true

FactoryBot.define do
  factory :access_token, class: "Doorkeeper::AccessToken" do
    scopes { "public" }
    association :application
  end
end
