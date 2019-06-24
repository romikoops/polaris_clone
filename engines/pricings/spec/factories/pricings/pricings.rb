# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory :pricings_pricing, class: 'Pricings::Pricing' do # rubocop:disable Metrics/BlockLength
    wm_rate { 'Gothenburg' }
    effective_date { Date.today }
    expiration_date { 6.months.from_now }
    cargo_class { 'lcl' }
    load_type { 'cargo_item' }
    association :tenant, factory: :legacy_tenant
    association :itinerary, factory: :legacy_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle

    trait :lcl do
      cargo_class { 'lcl' }
      load_type { 'cargo_item' }
      after :create do |pricing|
        create_list(:pricings_fee,
                    1,
                    pricing: pricing,
                    tenant: pricing.tenant,
                    rate_basis: FactoryBot.create(:per_wm),
                    rate: 25,
                    charge_category: FactoryBot.create(:bas_charge))
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
                    charge_category: FactoryBot.create(:bas_charge))
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
                    charge_category: FactoryBot.create(:bas_charge))
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
                    charge_category: FactoryBot.create(:bas_charge))
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

    factory :lcl_pricing, traits: [:lcl]
    factory :lcl_range_pricing, traits: [:lcl_range]
    factory :container_range_pricing, traits: [:container_range]
    factory :fcl_20_pricing, traits: [:fcl_20]
    factory :fcl_40_pricing, traits: [:fcl_40]
    factory :fcl_40_hq_pricing, traits: [:fcl_40_hq]
  end
end
