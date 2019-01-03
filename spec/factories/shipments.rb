# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user
    association :origin_hub, factory: :hub
    association :destination_hub, factory: :hub
    association :trip
    load_type :container
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
      with_breakdown false
    end

    before(:create) do |shipment, evaluator|
      if shipment.itinerary.nil?
        shipment.itinerary_id = shipment.trip.itinerary_id
      end

      shipment.origin_nexus = shipment.origin_hub.nexus
      shipment.destination_nexus = shipment.destination_hub.nexus

      shipment.shipment_contacts << build(:shipment_contact, shipment: shipment, contact_type: :shipper)
      shipment.shipment_contacts << build(:shipment_contact, shipment: shipment, contact_type: :consignee)

      if evaluator.with_breakdown
        shipment.charge_breakdowns << create(:charge_breakdown, trip: shipment.trip, shipment: shipment)
      end
    end
  end
end
