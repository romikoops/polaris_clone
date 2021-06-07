# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::QuotationService do
  let(:scope_content) { {} }
  let(:scope) { FactoryBot.build(:organizations_scope, content: scope_content) }
  let(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }
  let(:air_itinerary) do
    FactoryBot.create(:hamburg_shanghai_itinerary, mode_of_transport: "air", organization: organization)
  end
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:origin_airport) { air_itinerary.origin_hub }
  let(:destination_airport) { air_itinerary.destination_hub }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:load_type) { "cargo_item" }
  let(:direction) { "export" }
  let(:base_shipping_info) do
    {
      trucking_info: { pre_carriage: { truck_type: "" }, on_carriage: { truck_type: "" } }
    }
  end
  let(:cargo_item_attributes) do
    [
      {
        "payload_in_kg" => 120,
        "total_volume" => 0,
        "total_weight" => 0,
        "width" => 120,
        "length" => 80,
        "height" => 120,
        "quantity" => 1,
        "cargo_item_type_id" => pallet.id,
        "dangerous_goods" => false,
        "stackable" => true
      }
    ]
  end
  let(:containers_attributes) do
    [
      {
        "payload_in_kg" => 120,
        "size_class" => "fcl_20",
        "cargo_class" => "fcl_20",
        "quantity" => 1,
        "dangerous_goods" => false
      }
    ]
  end
  let(:input) do
    { organization_id: organization.id,
      user_id: user.id,
      creator_id: user.id,
      direction: direction,
      load_type: load_type,
      selected_date: Time.zone.today }
  end
  let(:port_to_port_input) do
    input[:origin] = { nexus_id: origin_hub.nexus_id }
    input[:destination] = { nexus_id: destination_hub.nexus_id }
    input
  end
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:hamburg_address) { FactoryBot.create(:hamburg_address) }
  let(:door_to_door_input) do
    input[:origin] = {
      latitude: hamburg_address.latitude,
      longitude: hamburg_address.longitude,
      fullAddress: hamburg_address.geocoded_address,
      country: hamburg_address.country.name,
      number: hamburg_address.street_number,
      street: hamburg_address.street,
      zip_code: hamburg_address.zip_code
    }
    input[:destination] = {
      latitude: shanghai_address.latitude,
      longitude: shanghai_address.longitude,
      fullAddress: shanghai_address.geocoded_address,
      country: shanghai_address.country.name,
      number: shanghai_address.street_number,
      street: shanghai_address.street,
      zip_code: shanghai_address.zip_code
    }
    input
  end
  let(:origin_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: hamburg_address.latitude, lng: hamburg_address.longitude,
                                               delta: 0.4),
      country_code: "de")
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: shanghai_address.latitude, lng: shanghai_address.longitude,
                                               delta: 0.4),
      country_code: "cn")
  end
  let(:origin_trucking_location) do
    FactoryBot.create(:trucking_location, query: :location, location: origin_location,
                                          country_code: "DE")
  end
  let(:destination_trucking_location) do
    FactoryBot.create(:trucking_location, query: :location, location: destination_location,
                                          country_code: "CN")
  end
  let(:quotation_details) { port_to_port_input }
  let(:shipping_info) { base_shipping_info }
  let(:source) { FactoryBot.create(:application) }
  let(:service) do
    described_class.new(
      organization: organization,
      quotation_details: quotation_details.with_indifferent_access,
      shipping_info: shipping_info,
      source: source
    )
  end
  let(:query) { service.result }
  let(:origin_response) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination_response) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
  let(:results) { query.result_sets.order(:created_at).last.results }

  before do
    [itinerary, air_itinerary].product(%w[container cargo_item]).each do |it, load|
      FactoryBot.create(:trip_with_layovers, itinerary: it, load_type: load, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:trip_with_layovers,
        itinerary: it,
        load_type: load,
        tenant_vehicle: tenant_vehicle,
        start_date: 10.days.from_now,
        end_date: 30.days.from_now)
    end
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin_response)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination_response)
    FactoryBot.create(:legacy_tenant_cargo_item_type, cargo_item_type: pallet, organization: organization)
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, organization: organization, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:lcl_pricing, itinerary: air_itinerary, organization: organization,
                                    tenant_vehicle: tenant_vehicle)
    %w[ocean trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(
          :freight_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :trucking_on_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :trucking_pre_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :import_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        ),
        FactoryBot.create(
          :export_margin, default_for: mot, organization: organization, applicable: organization, value: 0
        )
      ]
    end
    ::Organizations.current_id = organization.id
  end

  describe ".perform" do
    context "when port to port (defaults)" do
      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "when port to port (containers provided)" do
      let(:shipping_info) { base_shipping_info.merge(containers_attributes: containers_attributes) }
      let(:load_type) { "container" }

      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "when door to door (defaults & container)" do
      include_context "complete_route_with_trucking"
      before do
        # rubocop:disable RSpec/AnyInstance
        allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time)
          .and_return(10)
        # rubocop:enable RSpec/AnyInstance
      end

      let(:load_type) { "container" }
      let(:cargo_classes) { ["fcl_20"] }
      let(:shipping_info) do
        {
          trucking_info: { pre_carriage: { truck_type: "chassis" }, on_carriage: { truck_type: "chassis" } }
        }
      end
      let(:quotation_details) { door_to_door_input }

      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "when port to port (defaults & quote & container)" do
      let(:scope_content) { { closed_quotation_tool: true } }

      let(:load_type) { "container" }

      it "perform a quote calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "when port to port (with cargo)" do
      let(:shipping_info) do
        {
          cargo_items_attributes: cargo_item_attributes
        }
      end

      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "when failing in OfferCalculator" do
      let(:offer_calculator_error_map) do
        {
          "OfferCalculator::Errors::InvalidFreightResult": "The system was unable to calculate a valid set of freight charges for this booking.",
          "ArgumentError": "Something has gone wrong!"
        }
      end
      let(:shipping_info) do
        {
          cargo_items_attributes: cargo_item_attributes
        }
      end

      let(:offer_calculator_double) { instance_double(::OfferCalculator::Calculator) }

      before do
        allow(::OfferCalculator::Calculator).to receive(:new).and_return(offer_calculator_double)
      end

      it "rescues errors from the offer calculator service and spews the right messages" do
        offer_calculator_error_map.each do |key, message|
          allow(offer_calculator_double).to receive(:perform).and_raise(key.to_s.constantize)
          expect { service.result }.to raise_error(Wheelhouse::ApplicationError, message)
        end
      end
    end
  end
end
