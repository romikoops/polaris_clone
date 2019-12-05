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
    sequence(:imc_reference) { |n| "#{SecureRandom.hex}#{n}" }

    total_goods_value do
      {
        value: 100,
        currency: :EUR
      }
    end

    transient do
      with_breakdown { false }
      with_aggregated_cargo { false }
    end

    trait :with_contacts do
      after(:build) do |shipment|
        shipment.shipment_contacts << build(:legacy_shipment_contact, contact_type: :shipper)
        shipment.shipment_contacts << build(:legacy_shipment_contact, contact_type: :consignee)
        shipment.shipment_contacts << build_list(:legacy_shipment_contact, 2, contact_type: :notifyee)
      end
    end

    before(:create) do |shipment, evaluator|
      shipment.itinerary_id = shipment.trip.itinerary_id if shipment.itinerary.nil?

      shipment.origin_nexus = shipment.origin_hub.nexus
      shipment.destination_nexus = shipment.destination_hub.nexus

      if evaluator.with_aggregated_cargo
        create(:legacy_aggregated_cargo, shipment: shipment)
      else
        shipment.cargo_units << create("legacy_#{shipment.load_type}".to_sym, shipment: shipment)
      end

      if evaluator.with_breakdown
        shipment.charge_breakdowns << create(:charge_breakdown, trip: shipment.trip, shipment: shipment)
      end
    end

    factory :complete_legacy_shipment, traits: %i(with_contacts)
  end
end
