FactoryBot.define do
  factory :journey_line_item, class: "Journey::LineItem" do
    association :line_item_set, factory: :journey_line_item_set
    association :route_section, factory: :journey_route_section
    association :route_point, factory: :journey_route_point
    total_cents { 3000 }
    total_currency { "USD" }
    unit_price_cents { 1000 }
    unit_price_currency { "USD" }
    units { 3 }
    sequence(:fee_code) { |n| "Fee #{n}" }
    note { "" }
    description { "" }
    included { false }
    optional { false }
    sequence(:order) { |n| n }
    wm_rate { 1000 }
  end
end
