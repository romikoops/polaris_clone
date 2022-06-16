# frozen_string_literal: true

FactoryBot.define do
  factory :api_user, class: "Api::User", parent: :users_user do
    activation_state { "active" }
  end
end
