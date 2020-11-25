FactoryBot.define do
  factory :journey_cargo_unit, class: "Journey::CargoUnit" do
    quantity { 2 }
    weight_value { 3000 }
    width_value { 1.20 }
    length_value { 0.80 }
    height_value { 1.40 }
    stackable { false }
    cargo_class { "lcl" }
    association :query, factory: :journey_query
  end
end
