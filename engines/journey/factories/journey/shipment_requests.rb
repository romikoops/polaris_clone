FactoryBot.define do
  factory :journey_shipment_request, class: "Journey::ShipmentRequest" do
    association :result, factory: :journey_result
    association :company, factory: :companies_company
    association :client, factory: :organizations_user
    preferred_voyage { "1234" }
  end
end
