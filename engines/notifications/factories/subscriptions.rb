# frozen_string_literal: true

FactoryBot.define do
  factory :notifications_subscriptions, class: "Notifications::Subscription" do
    association :user, factory: :users_user
    association :organization, factory: :organizations_organization
    filter { {} }
    sequence(:email) { |n| "john.doe.#{n}@itsmycargo.test" }
    event_type { "Journey::OfferCreated" }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
  end
end
