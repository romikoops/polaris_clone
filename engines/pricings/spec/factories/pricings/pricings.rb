# frozen_string_literal: true

FactoryBot.define do
  factory :pricings_pricing, class: 'Pricings::Pricing' do
    wm_rate { 'Gothenburg' }
    effective_date { Time.zone.today }
    expiration_date { 6.months.from_now }
    cargo_class { 'lcl' }
    load_type { 'cargo_item' }
    association :tenant, factory: :legacy_tenant
    association :itinerary, factory: :default_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle

    transient do
      fee_attrs { {} }
    end

    after :create do |pricing, evaluator|
      unless evaluator.fee_attrs.empty?
        fee_options = { pricing: pricing,
                        tenant: pricing.tenant,
                        rate_basis: FactoryBot.create(evaluator.fee_attrs[:rate_basis]) }
        fee_options.merge!(evaluator.fee_attrs.except(:rate_basis))
        create_list :pricings_fee, 1, **fee_options
      end
    end

    trait :lcl do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant,
                    rate_basis: FactoryBot.create(:per_wm_rate_basis),
                    rate: 25,
                    charge_category: FactoryBot.create(:bas_charge, tenant: pricing.tenant))
      end
    end
    trait :fcl_20 do
      cargo_class { 'fcl_20' }
      load_type { 'container' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant,
                    rate_basis: FactoryBot.create(:per_container),
                    rate: 250,
                    charge_category: FactoryBot.create(:bas_charge, tenant: pricing.tenant))
      end
    end

    trait :fcl_40 do
      cargo_class { 'fcl_40' }
      load_type { 'container' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant,
                    rate_basis: FactoryBot.create(:per_container),
                    rate: 250,
                    charge_category: FactoryBot.create(:bas_charge, tenant: pricing.tenant))
      end
    end

    trait :fcl_40_hq do
      cargo_class { 'fcl_40_hq' }
      load_type { 'container' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant,
                    rate_basis: FactoryBot.create(:per_container),
                    rate: 250,
                    charge_category: FactoryBot.create(:bas_charge, tenant: pricing.tenant))
      end
    end

    trait :lcl_range do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:fee_per_kg_range,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant)
      end
    end

    trait :container_range do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:fee_per_container_range,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant)
      end
    end

    trait :fully_loaded_lcl do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create(:pricings_fee,
                  pricing: pricing,
                  tenant: pricing.tenant,
                  rate_basis: FactoryBot.create(:per_wm_rate_basis),
                  rate: 25,
                  charge_category: FactoryBot.create(:bas_charge, tenant: pricing.tenant))
        create(:fee_per_kg_range,
                  pricing: pricing,
                  tenant: pricing.tenant,
                  charge_category: FactoryBot.create(:solas_charge, tenant: pricing.tenant))
      end
    end

    factory :loaded_lcl_pricing, traits: [:fully_loaded_lcl]
    factory :lcl_pricing, traits: [:lcl]
    factory :lcl_range_pricing, traits: [:lcl_range]
    factory :container_range_pricing, traits: [:container_range]
    factory :fcl_20_pricing, traits: [:fcl_20]
    factory :fcl_40_pricing, traits: [:fcl_40]
    factory :fcl_40_hq_pricing, traits: [:fcl_40_hq]
  end
end

# == Schema Information
#
# Table name: pricings_pricings
#
#  id                :uuid             not null, primary key
#  cargo_class       :string
#  effective_date    :datetime
#  expiration_date   :datetime
#  internal          :boolean          default(FALSE)
#  load_type         :string
#  validity          :daterange
#  wm_rate           :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  group_id          :uuid
#  itinerary_id      :bigint
#  legacy_id         :integer
#  sandbox_id        :uuid
#  tenant_id         :bigint
#  tenant_vehicle_id :integer
#  user_id           :bigint
#
# Indexes
#
#  index_pricings_pricings_on_cargo_class        (cargo_class)
#  index_pricings_pricings_on_itinerary_id       (itinerary_id)
#  index_pricings_pricings_on_load_type          (load_type)
#  index_pricings_pricings_on_sandbox_id         (sandbox_id)
#  index_pricings_pricings_on_tenant_id          (tenant_id)
#  index_pricings_pricings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_pricings_pricings_on_user_id            (user_id)
#  index_pricings_pricings_on_validity           (validity) USING gist
#
