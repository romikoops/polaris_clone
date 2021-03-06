# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_fee, class: "Pricings::Fee" do
    rate { 1111 }
    min { 1 }
    association :rate_basis, factory: :pricings_rate_basis
    association :charge_category, factory: :bas_charge
    association :organization, factory: :organizations_organization
    currency_name { "EUR" }
    base { 1e-6 }

    trait :per_wm do
      association :rate_basis, factory: :per_wm_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_cbm_kg_heavy do
      association :rate_basis, factory: :per_wm_rate_basis
      association :hw_rate_basis, factory: :per_kg_per_cbm_rate_basis
      association :charge_category, factory: :has_charge
      hw_threshold { 550 }
      rate { 4 }
      min { 10 }
    end

    trait :per_item_heavy do
      association :rate_basis, factory: :per_wm_rate_basis
      association :hw_rate_basis, factory: :per_item_rate_basis
      association :charge_category, factory: :has_charge
      hw_threshold { 100 }
      range do
        [
          {min: 1500, max: 2000, rate: 100},
          {min: 2001, max: 2500, rate: 250}
        ]
      end
    end

    trait :per_container do
      association :rate_basis, factory: :per_container_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_hbl do
      association :rate_basis, factory: :per_hbl_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_shipment do
      association :rate_basis, factory: :per_shipment_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_item do
      association :rate_basis, factory: :per_item_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_cbm do
      association :rate_basis, factory: :per_cbm_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_kg do
      association :rate_basis, factory: :per_kg_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_x_kg_flat do
      base { 100 }
      rate { 0.025 }
      min { 25 }
      association :rate_basis, factory: :per_x_kg_flat_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_cbm_ton do
      association :rate_basis, factory: :per_cbm_ton_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_ton do
      association :rate_basis, factory: :per_ton_rate_basis
      association :charge_category, factory: :bas_charge
    end

    trait :per_kg_range do
      association :rate_basis, factory: :per_kg_range_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 100, rate: 10},
          {min: 101, max: 500, rate: 8},
          {min: 501, max: 1000, rate: 6},
          {min: 1001, max: 2000, rate: 5}
        ]
      end
    end

    trait :per_kg_range_flat do
      association :rate_basis, factory: :per_kg_range_flat_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 100, rate: 20},
          {min: 101, max: 500, rate: 15},
          {min: 501, max: 1000, rate: 12}
        ]
      end
    end

    trait :per_unit_ton_cbm_range do
      association :rate_basis, factory: :per_unit_ton_cbm_range_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 5, cbm: 100},
          {min: 5, max: 25, ton: 80}
        ]
      end
    end
    trait :per_container_range do
      association :rate_basis, factory: :per_container_range_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 4, rate: 10},
          {min: 5, max: 10, rate: 8},
          {min: 11, max: 20, rate: 6}
        ]
      end
    end
    trait :per_unit_range do
      association :rate_basis, factory: :per_unit_range_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 5, rate: 10},
          {min: 6, max: 10, rate: 8},
          {min: 11, max: 20, rate: 6}
        ]
      end
    end

    trait :per_container_range_flat do
      association :rate_basis, factory: :per_container_range_flat_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 4, rate: 10},
          {min: 5, max: 10, rate: 8},
          {min: 11, max: 20, rate: 6}
        ]
      end
    end

    trait :per_unit_range_flat do
      association :rate_basis, factory: :per_unit_range_flat_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0, max: 5, rate: 10},
          {min: 6, max: 10, rate: 8},
          {min: 11, max: 20, rate: 6}
        ]
      end
    end

    trait :per_cbm_range do
      association :rate_basis, factory: :per_cbm_range_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0.0, max: 4.9, rate: 8},
          {min: 5.0, max: 10, rate: 12}
        ]
      end
    end

    trait :per_wm_range do
      association :rate_basis, factory: :per_wm_range_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0.0, max: 4.9, rate: 8},
          {min: 5.0, max: 10, rate: 12}
        ]
      end
    end

    trait :per_cbm_range_flat do
      association :rate_basis, factory: :per_cbm_range_flat_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0.0, max: 4.9, rate: 8},
          {min: 5.0, max: 10, rate: 12}
        ]
      end
    end

    trait :per_wm_range_flat do
      association :rate_basis, factory: :per_wm_range_flat_rate_basis
      association :charge_category, factory: :bas_charge
      range do
        [
          {min: 0.0, max: 4.9, rate: 8},
          {min: 5.0, max: 10, rate: 12}
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
    factory :fee_per_kg_range_flat, traits: [:per_kg_range_flat]
    factory :fee_per_unit_ton_cbm_range, traits: [:per_unit_ton_cbm_range]
    factory :fee_per_container_range, traits: [:per_container_range]
    factory :fee_per_unit_range, traits: [:per_unit_range]
    factory :fee_per_container_range_flat, traits: [:per_container_range_flat]
    factory :fee_per_unit_range_flat, traits: [:per_unit_range_flat]
    factory :fee_per_cbm_range, traits: [:per_cbm_range]
    factory :fee_per_wm_range, traits: [:per_wm_range]
    factory :fee_per_cbm_range_flat, traits: [:per_cbm_range_flat]
    factory :fee_per_wm_range_flat, traits: [:per_wm_range_flat]
    factory :fee_per_cbm_kg_heavy, traits: [:per_cbm_kg_heavy]
    factory :fee_per_item_heavy, traits: [:per_item_heavy]
  end
end

# == Schema Information
#
# Table name: pricings_fees
#
#  id                 :uuid             not null, primary key
#  base               :decimal(, )
#  currency_name      :string
#  hw_threshold       :decimal(, )
#  metadata           :jsonb
#  min                :decimal(, )
#  range              :jsonb
#  rate               :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  charge_category_id :integer
#  currency_id        :bigint
#  hw_rate_basis_id   :uuid
#  legacy_id          :integer
#  organization_id    :uuid
#  pricing_id         :uuid
#  rate_basis_id      :uuid
#  sandbox_id         :uuid
#  tenant_id          :bigint
#
# Indexes
#
#  index_pricings_fees_on_organization_id  (organization_id)
#  index_pricings_fees_on_pricing_id       (pricing_id)
#  index_pricings_fees_on_sandbox_id       (sandbox_id)
#  index_pricings_fees_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
