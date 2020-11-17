# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_meta, class: "Hash" do
    skip_create

    initialize_with do
      {
        itinerary_id: 1,
        destination_hub: FactoryBot.create(:shanghai_hub),
        charge_trip_id: 1,
        transit_time: 25,
        load_type: "cargo_item",
        mode_of_transport: "ocean",
        name: "Gothenburg - Shanghai",
        service_level: "standard",
        carrier_name: "MSC",
        origin_hub: FactoryBot.create(:gothenburg_hub),
        tenant_vehicle_id: 1,
        shipment_id: 1,
        ocean_chargeable_weight: "1000.0",
        transshipmentVia: "ZACPT",
        validUntil: Time.zone.today + 30.days,
        remarkNotes: [],
        pricing_rate_data: {}
      }
    end
  end
end
