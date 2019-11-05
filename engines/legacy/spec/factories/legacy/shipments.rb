# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_shipment, class: 'Legacy::Shipment' do
    association :user, factory: :legacy_user
    association :origin_hub, factory: :legacy_hub
    association :destination_hub, factory: :legacy_hub
    association :trip, factory: :legacy_trip
    association :tenant, factory: :legacy_tenant
    load_type { :container }
    booking_placed_at { Date.today }
    planned_etd { Date.tomorrow + 7.days + 2.hours }
    planned_eta { Date.tomorrow + 11.days }
    closing_date { Date.tomorrow + 4.days + 5.hours }

    total_goods_value do
      {
        value: 100,
        currency: :EUR
      }
    end

    transient do
      with_breakdown { false }
    end

    before(:create) do |shipment, evaluator|
      shipment.itinerary_id = shipment.trip.itinerary_id if shipment.itinerary.nil?

      shipment.origin_nexus = shipment.origin_hub.nexus
      shipment.destination_nexus = shipment.destination_hub.nexus
      shipment.cargo_units << create("legacy_#{shipment.load_type}".to_sym, shipment: shipment)

      if evaluator.with_breakdown
        shipment.charge_breakdowns << create(:charge_breakdown, trip: shipment.trip, shipment: shipment)
      end
    end
  end
end
