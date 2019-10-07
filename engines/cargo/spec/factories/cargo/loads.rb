# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_load, class: 'Cargo::Load' do
    transient do
      aggregated { false }
    end

    after(:build) do |cargo_load, evaluator|
      unless evaluator.aggregated || cargo_load.groups.present?
        cargo_load.groups << build(:cargo_group,
                                   tenant: cargo_load.tenant,
                                   user: cargo_load.user,
                                   load: cargo_load,
                                   cargo_class: cargo_load.cargo_class,
                                   cargo_type: cargo_load.cargo_type)
      end
    end

    quantity { 2 }
    weight { 3000.0 }
    volume { 2.688 }
    cargo_class { 1 }
    association :user, factory: :tenants_user
    association :tenant, factory: :tenants_tenant

    trait :cargo_item do
      cargo_class { Cargo::Load::CLASS_ENUM_HASH.key('00') }
    end

    trait :fcl_multi do
      after(:build) do |cargo_load|
        %i(fcl_20_group fcl_40_group fcl_40_hq_group fcl_45_group).each do |sym|
          cargo_load.groups << build(sym,
                                     tenant: cargo_load.tenant,
                                     user: cargo_load.user,
                                     load: cargo_load)
        end
      end
    end

    trait :fcl_20 do
      quantity { 1 }
      weight { 15_000.0 }
      volume {}
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

    factory :cargo_item_load, traits: [:cargo_item]
    factory :container_20, traits: [:fcl_20]
    factory :container_40, traits: [:fcl_40]
    factory :container_40_hq, traits: [:fcl_40_hq]
    factory :container_45, traits: [:fcl_45]
  end
end
