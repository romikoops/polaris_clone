# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_aggregated_cargo, class: 'Legacy::AggregatedCargo' do
    association :shipment, factory: :legacy_shipment

    weight { 200 }
    volume { 1.0 }
    chargeable_weight { 1000 }
  end
end
