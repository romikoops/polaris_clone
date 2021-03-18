# frozen_string_literal: true
FactoryBot.define do
  factory :journey_cargo_unit, class: "Journey::CargoUnit" do
    quantity { 2 }
    weight_value { 3000 }
    width_value { 1.20 }
    length_value { 0.80 }
    height_value { 1.40 }
    stackable { false }
    cargo_class { "lcl" }
    colli_type { "pallet" }
    association :query, factory: :journey_query

    trait :fcl do
      colli_type { "container" }
      cargo_class { "fcl_20" }
      quantity { 2 }
      weight_value { 3000 }
      width_value { }
      length_value { }
      height_value { }
    end

    trait :aggregate_lcl do
      colli_type { }
      cargo_class { "aggregated_lcl" }
      quantity { 1 }
      weight_value { 3000 }
      volume_value { 1.30 }
    end

    after(:build) do |cargo_unit|
      cargo_unit.set_volume if cargo_unit.dimensions_required?
    end
  end
end
