# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :pricings_rate_basis, class: 'Pricings::RateBasis' do # rubocop:disable Metrics/BlockLength
    internal_code { 'PER_CONTAINER' }
    external_code { 'PER_CONTAINER' }

    trait :container do
      internal_code { 'PER_CONTAINER' }
      external_code { 'PER_CONTAINER' }
    end

    trait :wm do
      internal_code { 'PER_WM' }
      external_code { 'PER_WM' }
    end

    trait :hbl do
      internal_code { 'PER_SHIPMENT' }
      external_code { 'PER_HBL' }
    end

    trait :shipment do
      internal_code { 'PER_SHIPMENT' }
      external_code { 'PER_SHIPMENT' }
    end

    trait :item do
      internal_code { 'PER_ITEM' }
      external_code { 'PER_ITEM' }
    end

    trait :cbm do
      internal_code { 'PER_CBM' }
      external_code { 'PER_CBM' }
    end

    trait :kg do
      internal_code { 'PER_KG' }
      external_code { 'PER_KG' }
    end

    trait :kg_per_cbm do
      internal_code { 'CBM_PER_KG' }
      external_code { 'CBM_PER_KG' }
    end

    trait :x_kg_flat do
      internal_code { 'PER_X_KG_FLAT' }
      external_code { 'PER_X_KG_FLAT' }
    end

    trait :cbm_ton do
      internal_code { 'PER_CBM_TON' }
      external_code { 'PER_CBM_TON' }
    end

    trait :ton do
      internal_code { 'PER_TON' }
      external_code { 'PER_TON' }
    end

    trait :kg_range do
      internal_code { 'PER_KG_RANGE' }
      external_code { 'PER_KG_RANGE' }
    end

    trait :unit_ton_cbm_range do
      internal_code { 'PER_UNIT_TON_CBM_RANGE' }
      external_code { 'PER_UNIT_TON_CBM_RANGE' }
    end

    trait :container_range do
      internal_code { 'PER_CONTAINER_RANGE' }
      external_code { 'PER_CONTAINER_RANGE' }
    end

    trait :unit_range do
      internal_code { 'PER_UNIT_RANGE' }
      external_code { 'PER_UNIT_RANGE' }
    end

    factory :per_wm, traits: [:wm]
    factory :per_container, traits: [:container]
    factory :per_hbl, traits: [:hbl]
    factory :per_shipment, traits: [:shipment]
    factory :per_item, traits: [:item]
    factory :per_cbm, traits: [:cbm]
    factory :per_kg, traits: [:kg]
    factory :per_kg_per_cbm, traits: [:kg_per_cbm]
    factory :per_x_kg_flat, traits: [:x_kg_flat]
    factory :per_cbm_ton, traits: [:cbm_ton]
    factory :per_ton, traits: [:ton]
    factory :per_kg_range, traits: [:kg_range]
    factory :per_unit_ton_cbm_range, traits: [:unit_ton_cbm_range]
    factory :per_container_range, traits: [:container_range]
    factory :per_unit_range, traits: [:unit_range]
  end
end
