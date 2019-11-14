# frozen_string_literal: true

FactoryBot.define do
  factory :shipments_unit, class: 'Shipments::Unit' do
    quantity { 2 }
    weight_value { 3000 }
    cargo_class { '00' }
    stackable { false }
    goods_value_cents { 1_000 }
    goods_value_currency { :usd }

    association :cargo, factory: :shipments_cargo

    trait :fcl do
    end

    trait :lcl do
      width_value { 1.20 }
      length_value { 0.80 }
      height_value { 1.40 }
      volume_value { (width_value * length_value * height_value) }
      cargo_class { '00' }
      cargo_type { 'LCL' }
    end

    trait :aggregated do
      volume_value { 1.3 }
      height_value { Cargo::Specification::DEFAULT_HEIGHT }
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

    factory :shipment_lcl_unit, traits: %i(lcl)
    factory :shipment_aggregated_unit, traits: %i(aggregated)
    factory :shipment_fcl_20_unit, traits: %i(fcl fcl_20)
    factory :shipment_fcl_40_unit, traits: %i(fcl fcl_40)
    factory :shipment_fcl_40_hq_unit, traits: %i(fcl fcl_40_hq)
    factory :shipment_fcl_45_unit, traits: %i(fcl fcl_45)
  end
end
