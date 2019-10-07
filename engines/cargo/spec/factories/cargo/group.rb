# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_group, class: 'Cargo::Group' do
    dimension_x { 120.0 }
    dimension_y { 80.0 }
    dimension_z { 140.0 }
    quantity { 2 }
    weight { 3000.0 }
    cargo_class { 1 }
    association :user, factory: :tenants_user
    association :tenant, factory: :tenants_tenant
    association :load, factory: :cargo_load

    trait :fcl do
      dimension_x {}
      dimension_y {}
      dimension_z {}
      weight { 30_000.0 }
    end

    trait :fcl_20 do
      cargo_class { Cargo::Load::CLASS_ENUM_HASH.key('20') }
    end

    trait :fcl_40 do
      cargo_class { Cargo::Load::CLASS_ENUM_HASH.key('40') }
    end

    trait :fcl_40_hq do
      cargo_class { Cargo::Load::CLASS_ENUM_HASH.key('45') }
    end

    trait :fcl_45 do
      cargo_class { Cargo::Load::CLASS_ENUM_HASH.key('L0') }
    end

    factory :fcl_20_group, traits: %i(fcl fcl_20)
    factory :fcl_40_group, traits: %i(fcl fcl_40)
    factory :fcl_40_hq_group, traits: %i(fcl fcl_40_hq)
    factory :fcl_45_group, traits: %i(fcl fcl_45)
  end
end
