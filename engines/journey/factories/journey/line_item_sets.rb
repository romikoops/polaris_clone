FactoryBot.define do
  factory :journey_line_item_set, class: "Journey::LineItemSet" do
    association :result, factory: :journey_result
    association :shipment_request, factory: :journey_shipment_request
  end
end
