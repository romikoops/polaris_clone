# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_pricing_detail, class: 'Legacy::PricingDetail' do
    rate { 1111 }
    rate_basis { 'PER_CONTAINER' }
    shipping_type { 'BAS' }
    currency_name { 'EUR' }

    trait :per_container do
      rate_basis { 'PER_CONTAINER' }
    end

    trait :per_shipment do
      rate_basis { 'PER_SHIPMENT' }
    end

    trait :per_wm do
      rate_basis { 'PER_WM' }
    end

    trait :per_item do
      rate_basis { 'PER_ITEM' }
    end

    trait :per_cbm do
      rate_basis { 'PER_CBM' }
    end

    trait :per_kg do
      rate_basis { 'PER_KG' }
    end

    trait :per_kg_range do
      rate_basis { 'PER_KG_RANGE' }
    end

    trait :per_container_range do
      rate_basis { 'PER_CONTAINER_RANGE' }
    end

    factory :pd_per_wm, traits: [:per_wm]
    factory :pd_per_container, traits: [:per_container]
    factory :pd_per_shipment, traits: [:per_shipment]
    factory :pd_per_item, traits: [:per_item]
    factory :pd_per_cbm, traits: [:per_cbm]
    factory :pd_per_kg, traits: [:per_kg]
    factory :pd_per_kg_range, traits: [:per_kg_range]
    factory :pd_per_container_range, traits: [:per_container_range]
  end
end
