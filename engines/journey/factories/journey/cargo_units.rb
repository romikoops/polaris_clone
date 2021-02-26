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
      colli_type {}
      cargo_class { "fcl_20" }
      quantity { 2 }
      weight_value { 3000 }
      width_value { 0 }
      length_value { 0 }
      height_value { 0 }
    end

    trait :aggregate_lcl do
      colli_type {}
      cargo_class { "aggregate_lcl" }
      quantity { 1 }
      weight_value { 3000 }
      width_value { 1.0 }
      length_value { 1.0 }
      height_value { 1.30 }
    end
  end
end
