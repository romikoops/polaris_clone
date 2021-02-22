# frozen_string_literal: true
FactoryBot.define do
  factory :journey_document, class: "Journey::Document" do
    association :query, factory: :journey_query
    association :shipment_request, factory: :journey_shipment_request
    kind { :commercial_invoice }
  end
end
