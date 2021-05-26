# frozen_string_literal: true

FactoryBot.define do
  factory :journey_line_item, class: "Journey::LineItem" do
    association :line_item_set, factory: :journey_line_item_set
    route_section do
      association :journey_route_section, result: instance.line_item_set.result
    end
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
    chargeable_density { 1000 }
    exchange_rate { 1.2 }
  end
end
