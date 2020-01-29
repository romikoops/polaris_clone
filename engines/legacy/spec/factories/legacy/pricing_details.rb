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
      range do
        [
          { min: 0, max: 100, rate: 10 },
          { min: 101, max: 500, rate: 8 },
          { min: 501, max: 1000, rate: 6 }
        ]
      end
    end

    trait :per_container_range do
      rate_basis { 'PER_CONTAINER_RANGE' }
      range do
        [
          { min: 0, max: 5, rate: 100 },
          { min: 6, max: 10, rate: 80 },
          { min: 11, max: 15, rate: 60 },
          { min: 16, max: 20, rate: 60 }
        ]
      end
    end

    trait :per_item_heavy do
      rate_basis { 'PER_WM' }
      hw_rate_basis { 'PER_ITEM' }
      range do
        [
          { min: 1500, max: 2000, rate: 100 },
          { min: 2001, max: 2500, rate: 250 }
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

    trait :per_unit_range do
      rate_basis { 'PER_UNIT_RANGE' }
      range do
        [
          { min: 0, max: 5, rate: 100 },
          { min: 6, max: 10, rate: 80 },
          { min: 11, max: 15, rate: 60 },
          { min: 16, max: 20, rate: 60 }
        ]
      end
    end

    trait :per_cbm_kg_heavy do
      rate_basis { 'PER_WM' }
      hw_rate_basis { 'CBM_PER_KG' }
      hw_threshold { 550 }
      rate { 4 }
      min { 10 }
    end

    trait :per_ton do
      rate_basis { 'PER_TON' }
    end

    trait :per_hbl do
      rate_basis { 'PER_HBL' }
    end

    factory :pd_per_item_heavy, traits: [:per_item_heavy]
    factory :pd_per_unit_range, traits: [:per_unit_range]
    factory :pd_per_x_kg_flat, traits: [:per_x_kg_flat]
    factory :pd_per_cbm_kg_heavy, traits: [:per_cbm_kg_heavy]
    factory :pd_per_ton, traits: [:per_ton]
    factory :pd_per_hbl, traits: [:per_hbl]

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

# == Schema Information
#
# Table name: pricing_details
#
#  id             :bigint           not null, primary key
#  currency_name  :string
#  hw_rate_basis  :string
#  hw_threshold   :decimal(, )
#  min            :decimal(, )
#  priceable_type :string
#  range          :jsonb
#  rate           :decimal(, )
#  rate_basis     :string
#  shipping_type  :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  currency_id    :bigint
#  priceable_id   :bigint
#  sandbox_id     :uuid
#  tenant_id      :bigint
#
# Indexes
#
#  index_pricing_details_on_currency_id                      (currency_id)
#  index_pricing_details_on_priceable_type_and_priceable_id  (priceable_type,priceable_id)
#  index_pricing_details_on_sandbox_id                       (sandbox_id)
#  index_pricing_details_on_tenant_id                        (tenant_id)
#
