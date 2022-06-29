# frozen_string_literal: true

FactoryBot.define do
  factory :journey_addendum, class: "Journey::Addendum" do
    association :shipment_request, factory: :journey_shipment_request
    label_name { "contact_person" }
    value { "John Smith" }
  end
end
