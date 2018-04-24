# frozen_string_literal: true

FactoryBot.define do
  factory :container do
    size_class 'fcl_20' # TODO: set right size class
    weight_class '14t'
    payload_in_kg 10000
    tare_weight 1000
    gross_weight 11000
    cargo_class 'fcl_20'
    dangerous_goods false
    quantity 1
    association :shipment
  end
end
