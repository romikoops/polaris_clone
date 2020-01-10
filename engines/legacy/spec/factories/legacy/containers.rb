# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_container, class: 'Legacy::Container' do
    size_class { 'fcl_20' }
    weight_class { '14t' }
    payload_in_kg { 10_000 }
    tare_weight { 1000 }
    gross_weight { 11_000 }
    cargo_class { 'fcl_20' }
    dangerous_goods { false }
    quantity { 1 }
    association :shipment, factory: :legacy_shipment
  end
end
