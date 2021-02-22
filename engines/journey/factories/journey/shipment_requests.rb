# frozen_string_literal: true
FactoryBot.define do
  factory :journey_shipment_request, class: "Journey::ShipmentRequest" do
    association :result, factory: :journey_result
    association :company, factory: :companies_company
    association :client, factory: :users_client
    preferred_voyage { "1234" }
  end
end
