# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_fee, class: 'Pricings::Fee' do # rubocop:disable Metrics/BlockLength
    rate { 1111 }
    min { 1 }
    association :rate_basis, factory: :pricings_rate_bases
    association :charge_category, factory: :legacy_charge_categories
    association :tenant, factory: :legacy_tenant
    currency_name { 'EUR' }
    base { 1 }

    trait :per_wm do
      association :rate_basis, factory: :per_wm
      association :charge_category, factory: :bas_charge
    end

    trait :per_cbm_kg_heavy do
      association :rate_basis, factory: :per_wm
      association :hw_rate_basis, factory: :per_kg_per_cbm
      association :charge_category, factory: :has_charge
      hw_threshold { 550 }
      rate { 4 }
      min { 10 }
    end

    trait :per_item_heavy do
      association :rate_basis, factory: :per_wm
      association :hw_rate_basis, factory: :per_item
      association :charge_category, factory: :has_charge
      hw_threshold { 100 }
      range do
        [
          { min: 1500, max: 2000, rate: 100 },
          { min: 2001, max: 2500, rate: 250 }
        ]
      end
    end

    trait :per_container do
      association :rate_basis, factory: :per_container
      association :charge_category, factory: :bas_charge
    end

    trait :per_hbl do
      association :rate_basis, factory: :per_hbl
      association :charge_category, factory: :bas_charge
    end

    trait :per_shipment do
      association :rate_basis, factory: :per_shipment
      association :charge_category, factory: :bas_charge
    end

    trait :per_item do
      association :rate_basis, factory: :per_item
      association :charge_category, factory: :bas_charge
    end

    trait :per_cbm do
      association :rate_basis, factory: :per_cbm
      association :charge_category, factory: :bas_charge
    end

    trait :per_kg do
      association :rate_basis, factory: :per_kg
      association :charge_category, factory: :bas_charge
    end

    trait :per_x_kg_flat do
      base { 100 }
      rate { 25 }
      min { 25 }
      association :rate_basis, factory: :per_x_kg_flat
      association :charge_category, factory: :bas_charge
    end

    trait :per_cbm_ton do
      association :rate_basis, factory: :per_cbm_ton
      association :charge_category, factory: :bas_charge
    end

    trait :per_ton do
      association :rate_basis, factory: :per_ton
      association :charge_category, factory: :bas_charge
    end

    trait :per_kg_range do
      association :rate_basis, factory: :per_kg_range
      association :charge_category, factory: :bas_charge
      range do
        [
          { min: 0, max: 100, rate: 10 },
          { min: 101, max: 500, rate: 8 },
          { min: 501, max: 1000, rate: 6 }
        ]
      end
    end
    trait :per_unit_ton_cbm_range do
      association :rate_basis, factory: :per_unit_ton_cbm_range
      association :charge_category, factory: :bas_charge
      range do
        [
          { min: 0, max: 5, cbm: 100 },
          { min: 5, max: 25, ton: 80 }
        ]
      end
    end
    trait :per_container_range do
      association :rate_basis, factory: :per_container_range
      association :charge_category, factory: :bas_charge
      range do
        [
          { min: 0, max: 2000, rate: 100 },
          { min: 2001, max: 5000, rate: 80 },
          { min: 5001, max: 20_000, rate: 60 },
          { min: 20_001, max: 23_000, rate: 60 }
        ]
      end
    end
    trait :per_unit_range do
      association :rate_basis, factory: :per_unit_range
      association :charge_category, factory: :bas_charge
      range do
        [
          { min: 0, max: 5, rate: 100 },
          { min: 6, max: 10, rate: 80 },
          { min: 11, max: 20, rate: 60 }
        ]
      end
    end

    factory :fee_per_wm, traits: [:per_wm]
    factory :fee_per_container, traits: [:per_container]
    factory :fee_per_hbl, traits: [:per_hbl]
    factory :fee_per_shipment, traits: [:per_shipment]
    factory :fee_per_item, traits: [:per_item]
    factory :fee_per_cbm, traits: [:per_cbm]
    factory :fee_per_kg, traits: [:per_kg]
    factory :fee_per_x_kg_flat, traits: [:per_x_kg_flat]
    factory :fee_per_cbm_ton, traits: [:per_cbm_ton]
    factory :fee_per_ton, traits: [:per_ton]
    factory :fee_per_kg_range, traits: [:per_kg_range]
    factory :fee_per_unit_ton_cbm_range, traits: [:per_unit_ton_cbm_range]
    factory :fee_per_container_range, traits: [:per_container_range]
    factory :fee_per_unit_range, traits: [:per_unit_range]
    factory :fee_per_cbm_kg_heavy, traits: [:per_cbm_kg_heavy]
    factory :fee_per_item_heavy, traits: [:per_item_heavy]
  end
end
