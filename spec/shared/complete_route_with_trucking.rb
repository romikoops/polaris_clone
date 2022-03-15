# frozen_string_literal: true

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.shared_context "complete_route_with_trucking" do
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let!(:organization) { FactoryBot.create(:organizations_organization, theme: nil) }
  let(:pickup_address) { FactoryBot.create(:hamburg_address, country: origin_hub.address.country) }
  let(:delivery_address) { FactoryBot.create(:shanghai_address, country: destination_hub.address.country) }
  let(:carrier_lock) { false }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "IMC", code: "imc") }
  let(:tenant_vehicle) do
    FactoryBot.create(:legacy_tenant_vehicle, organization: organization, carrier_lock: carrier_lock, carrier: carrier)
  end
  let(:truck_type) { load_type == "cargo_item" ? "default" : "chassis" }
  let!(:max_dimensions) { FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization) }
  let!(:pricings) do
    cargo_classes.map do |cc|
      FactoryBot.create(:pricings_pricing,
        load_type: load_type,
        cargo_class: cc,
        organization: organization,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle,
        fee_attrs: { rate: 250, rate_basis: :per_unit_rate_basis, min: nil })
    end
  end
  let!(:local_charges) do
    cargo_classes.flat_map do |cc|
      %w[import export].map do |direction|
        FactoryBot.create(:legacy_local_charge,
          direction: direction,
          hub: direction == "export" ? itinerary.origin_hub : itinerary.destination_hub,
          load_type: cc,
          organization: organization,
          tenant_vehicle: tenant_vehicle)
      end
    end
  end
  let!(:margins) do
    [
      FactoryBot.create(:freight_margin,
        default_for: "ocean", organization: organization, applicable: organization, value: 0),
      FactoryBot.create(:trucking_on_margin,
        default_for: "trucking", organization: organization, applicable: organization, value: 0),
      FactoryBot.create(:trucking_pre_margin,
        default_for: "trucking", organization: organization, applicable: organization, value: 0),
      FactoryBot.create(:import_margin,
        default_for: "local_charge", organization: organization, applicable: organization, value: 0),
      FactoryBot.create(:export_margin,
        default_for: "local_charge", organization: organization, applicable: organization, value: 0)
    ]
  end
  let(:pickup_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: pickup_address.latitude, lng: pickup_address.longitude, delta: 0.4),
      country_code: pickup_address.country.code.downcase)
  end
  let(:delivery_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds,
        lat: delivery_address.latitude,
        lng: delivery_address.longitude,
        delta: 0.4),
      country_code: delivery_address.country.code.downcase)
  end
  let!(:trips) do
    [
      FactoryBot.create(:trip_with_layovers,
        itinerary: itinerary,
        load_type: load_type,
        tenant_vehicle: tenant_vehicle),
      FactoryBot.create(:trip_with_layovers,
        itinerary: itinerary,
        load_type: load_type,
        tenant_vehicle: tenant_vehicle,
        closing_date: 6.days.from_now,
        start_date: 10.days.from_now,
        end_date: 30.days.from_now)
    ]
  end
  let(:pickup_trucking_location) do
    FactoryBot.create(:trucking_location,
      :with_location,
      location: pickup_location,
      country: pickup_address.country)
  end
  let(:delivery_trucking_location) do
    FactoryBot.create(:trucking_location,
      :with_location,
      location: delivery_location,
      country: delivery_address.country)
  end
  let!(:truckings) do
    cargo_classes.flat_map do |cargo_class|
      [FactoryBot.create(:trucking_with_unit_rates,
        hub: itinerary.origin_hub,
        organization: organization,
        cargo_class: cargo_class,
        load_type: load_type,
        truck_type: truck_type,
        tenant_vehicle: tenant_vehicle,
        location: pickup_trucking_location),
        FactoryBot.create(:trucking_with_unit_rates,
          hub: itinerary.destination_hub,
          organization: organization,
          cargo_class: cargo_class,
          load_type: load_type,
          truck_type: truck_type,
          tenant_vehicle: tenant_vehicle,
          location: delivery_trucking_location,
          carriage: "on")]
    end
  end
  let!(:trucking_availbilities) do
    [
      FactoryBot.create(:trucking_hub_availability,
        hub: origin_hub,
        type_availability: factory_type_availability(
          carriage: "pre",
          load_type: load_type,
          query_method: :location,
          truck_type: truck_type,
          country: origin_hub.country
        )),
      FactoryBot.create(:trucking_hub_availability,
        hub: destination_hub,
        type_availability: factory_type_availability(
          carriage: "on",
          load_type: load_type,
          query_method: :location,
          truck_type: truck_type,
          country: destination_hub.country
        ))
    ]
  end

  before do
    Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "",
      "city" => origin_hub.name,
      "country" => origin_hub.nexus.country.name,
      "country_code" => origin_hub.nexus.country.code,
      "postal_code" => ""
    ])
    Geocoder::Lookup::Test.add_stub([destination_hub.latitude, destination_hub.longitude], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "",
      "city" => destination_hub.name,
      "country" => destination_hub.nexus.country.name,
      "country_code" => destination_hub.nexus.country.code,
      "postal_code" => ""
    ])
    Geocoder::Lookup::Test.add_stub([pickup_address.latitude, pickup_address.longitude], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => pickup_address.geocoded_address,
      "city" => pickup_address.city,
      "country" => pickup_address.country.name,
      "country_code" => pickup_address.country.code,
      "postal_code" => pickup_address.zip_code
    ])
    Geocoder::Lookup::Test.add_stub([delivery_address.latitude, delivery_address.longitude], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => delivery_address.geocoded_address,
      "city" => delivery_address.city,
      "country" => delivery_address.country.name,
      "country_code" => delivery_address.country.code,
      "postal_code" => delivery_address.zip_code
    ])
    FactoryBot.create(:routing_carrier, name: carrier.name, code: carrier.code)
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
