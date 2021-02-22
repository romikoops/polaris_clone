# frozen_string_literal: true
FactoryBot.define do
  factory :organizations_integration_token, class: "Organizations::IntegrationToken" do
    association :organization, factory: :organizations_organization

    scope { "pricings.upload" }
    token { SecureRandom.uuid }
    expires_at { 2.days.from_now }
  end
end
