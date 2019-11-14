# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_pricing, class: 'Legacy::Pricing' do
    wm_rate { 'Gothenburg' }
    effective_date { Date.today }
    expiration_date { 6.months.from_now }
    association :transport_category, factory: :legacy_transport_category
    association :tenant, factory: :legacy_tenant
    association :itinerary, factory: :default_itinerary
    association :tenant_vehicle, factory: :legacy_tenant_vehicle

    trait :lcl do
      transport_category { create(:ocean_lcl) }
      after :create do |pricing|
        create_list(:legacy_pricing_detail,
                    1,
                    priceable: pricing,
                    tenant: pricing.tenant,
                    rate_basis: 'PER_WM',
                    rate: 25)
      end
    end
    trait :fcl_20 do
      transport_category { create(:ocean_fcl_20) }
      after :create do |pricing|
        create_list(:pd_per_container,
                    1,
                    priceable: pricing,
                    tenant: pricing.tenant,
                    rate: 250)
      end
    end

    trait :fcl_40 do
      transport_category { create(:ocean_fcl_40) }
      after :create do |pricing|
        create_list(:pd_per_container,
                    1,
                    priceable: pricing,
                    tenant: pricing.tenant,
                    rate: 250)
      end
    end

    trait :fcl_40_hq do
      transport_category { create(:ocean_fcl_40_hq) }
      after :create do |pricing|
        create_list(:pd_per_container,
                    1,
                    priceable: pricing,
                    tenant: pricing.tenant,
                    rate: 250)
      end
    end

    trait :lcl_range do
      transport_category { create(:ocean_lcl) }
      after :create do |pricing|
        create_list(:pd_per_kg_range,
                    1,
                    priceable: pricing,
                    tenant: pricing.tenant)
      end
    end

    trait :container_range do
      transport_category { create(:ocean_fcl_20) }
      after :create do |pricing|
        create_list(:pd_per_container_range,
                    1,
                    priceable: pricing,
                    tenant: pricing.tenant)
      end
    end

    factory :legacy_lcl_pricing, traits: [:lcl]
    factory :legacy_lcl_range_pricing, traits: [:lcl_range]
    factory :legacy_container_range_pricing, traits: [:container_range]
    factory :legacy_fcl_20_pricing, traits: [:fcl_20]
    factory :legacy_fcl_40_pricing, traits: [:fcl_40]
    factory :legacy_fcl_40_hq_pricing, traits: [:fcl_40_hq]
  end
end
