# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_unit, class: 'Cargo::Unit' do
    quantity { 2 }
    weight_value { 3000 }
    cargo_class { '00' }
    cargo_type { 'GP' }
    goods_value_cents { 1_000 }
    goods_value_currency { :usd }
    association :tenant, factory: :tenants_tenant
    association :cargo, factory: :cargo_cargo

    trait :fcl do
    end

    trait :lcl do
      width_value { 1.20 }
      length_value { 0.80 }
      height_value { 1.40 }
      cargo_class { '00' }
      cargo_type { 'LCL' }
    end

    trait :aggregated do
      volume_value { 1.3 }
      cargo_class { '00' }
      cargo_type { 'AGR' }
      stackable { true }
    end

    trait :fcl_20 do
      cargo_class { '20' }
    end

    trait :fcl_40 do
      cargo_class { '40' }
    end

    trait :fcl_40_hq do
      cargo_class { '45' }
    end

    trait :fcl_45 do
      cargo_class { 'L0' }
    end

    factory :lcl_unit, traits: %i(lcl)
    factory :aggregated_unit, traits: %i(aggregated)
    factory :fcl_20_unit, traits: %i(fcl fcl_20)
    factory :fcl_40_unit, traits: %i(fcl fcl_40)
    factory :fcl_40_hq_unit, traits: %i(fcl fcl_40_hq)
    factory :fcl_45_unit, traits: %i(fcl fcl_45)
  end
end
