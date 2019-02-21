# frozen_string_literal: true

FactoryBot.define do
  factory :quotation do
    transient do
      shipment_count { 1 }
    end

    target_email { 'john@example.test' }
    name { 'NAME' }

    after(:build) do |quotation, evaluator|
      quotation.shipments = build_list(:shipment, evaluator.shipment_count)
    end
  end
end
