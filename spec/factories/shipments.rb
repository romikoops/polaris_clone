# frozen_string_literal: true

FactoryBot.define do
  factory :shipment do
    association :user, factory: :organizations_user
    association :origin_hub, factory: :hub
    association :destination_hub, factory: :hub
    association :trip
    load_type { :container }
    booking_placed_at { Time.zone.today }
    planned_etd { Time.zone.today + 8.days + 2.hours }
    planned_eta { Time.zone.today + 12.days }
    closing_date { Time.zone.today + 5.days + 5.hours }
    billing { :external }
    total_goods_value do
      {
        value: 100,
        currency: :EUR
      }
    end

    transient do
      with_breakdown { false }
      with_full_breakdown { false }
      with_aggregated_cargo { false }
    end

    trait :with_contacts do
      after(:build) do |shipment|
        shipment.shipment_contacts << build(:shipment_contact, contact_type: :shipper)
        shipment.shipment_contacts << build(:shipment_contact, contact_type: :consignee)
        shipment.shipment_contacts << build_list(:shipment_contact, 2, contact_type: :notifyee)
      end
    end

    before(:create) do |shipment, evaluator|
      shipment.itinerary_id = shipment.trip.itinerary_id if shipment.itinerary.nil?

      shipment.origin_nexus = shipment.origin_hub.nexus
      shipment.destination_nexus = shipment.destination_hub.nexus

      if evaluator.with_aggregated_cargo
        create(:aggregated_cargo, shipment: shipment)
      else
        shipment.cargo_units << create(shipment.load_type.to_s.to_sym, shipment: shipment)
      end

      if evaluator.with_breakdown
        shipment.charge_breakdowns << create(:charge_breakdown, trip: shipment.trip, shipment: shipment)
      end
    end

    factory :complete_shipment, traits: %i[with_contacts]
  end
end
