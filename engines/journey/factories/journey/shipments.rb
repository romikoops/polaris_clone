FactoryBot.define do
  factory :journey_shipment, class: "Journey::Shipment" do
    association :shipment_request, factory: :journey_shipment_request
  end
end
