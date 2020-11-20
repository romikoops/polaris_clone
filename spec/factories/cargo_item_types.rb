# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_item_type do
    width { 101 }
    length { 121 }
    description { "" }
    area { "" }
    category { "Pallet" }
  end
end
