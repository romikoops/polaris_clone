# frozen_string_literal: true

FactoryBot.define do
  factory :ledger_service, class: "Ledger::Service" do
    sequence(:name) { |n| "Service##{n}" }
    association :organization, factory: :organizations_organization
    association :carrier, factory: :routing_carrier
    mode_of_transport { "ocean" }
  end
end
