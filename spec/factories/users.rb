# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "demo#{n}@demo.com" }
    password 'demo123456789'
    association :tenant
    association :role
    association :optin_status
  end

end
