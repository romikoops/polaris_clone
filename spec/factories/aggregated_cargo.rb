# frozen_string_literal: true

FactoryBot.define do
  factory :aggregated_cargo do
    association :shipment

    weight { 200 }
    volume { 1.0 }
    chargeable_weight { 1000 }
  end
end
