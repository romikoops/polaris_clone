# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_cargo_item, class: 'Legacy::CargoItem' do
    association :shipment, factory: :legacy_shipment
    association :cargo_item_type, factory: :legacy_cargo_item_type

    payload_in_kg { 200 }
    dimension_x { 20 }
    dimension_y { 20 }
    dimension_z { 20 }
    quantity { 1 }
    dangerous_goods { false }
    stackable { true }
    cargo_class { 'lcl' }
  end
end
