FactoryBot.define do
  factory :journey_line_item_cargo_unit, class: "Journey::LineItemCargoUnit" do
    association :cargo_unit, factory: :journey_cargo_unit
    association :line_item, factory: :journey_line_item
  end
end
