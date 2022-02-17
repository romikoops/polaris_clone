# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Results do
  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  let(:load_type) { "container" }
  let(:company) { FactoryBot.create(:companies_company, organization: organization) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:query) do
    FactoryBot.create(:journey_query,
      load_type: :fcl,
      client: client,
      creator: client,
      company: company,
      cargo_count: 0,
      origin: pickup_address.geocoded_address,
      origin_coordinates: pickup_address.geo_point,
      destination: delivery_address.geocoded_address,
      destination_coordinates: delivery_address.geo_point,
      organization: organization)
  end
  let(:source) { FactoryBot.create(:application) }
  let(:container_attributes) do
    [
      {
        "payload_in_kg" => 12_000,
        "size_class" => "fcl_20",
        "quantity" => 1,
        "dangerous_goods" => false
      },
      {
        "payload_in_kg" => 12_000,
        "size_class" => "fcl_40",
        "quantity" => 1,
        "dangerous_goods" => false
      },
      {
        "payload_in_kg" => 12_000,
        "size_class" => "fcl_40_hq",
        "quantity" => 1,
        "dangerous_goods" => false
      }
    ]
  end
  let(:params) do
    FactoryBot.build(:journey_request_params,
      origin: pickup_carta,
      destination: delivery_carta,
      pickup_truck_type: "chassis",
      delivery_address: delivery_address,
      delivery_truck_type: "chassis",
      pickup_address: pickup_address,
      direction: "export",
      load_type: load_type,
      async: true,
      selected_day: 4.days.from_now.beginning_of_day.to_s,
      container_attributes: container_attributes)
  end
  let(:results) do
    described_class.new(
      query: query,
      params: params,
      pre_carriage: query_calculation.pre_carriage,
      on_carriage: query_calculation.on_carriage
    ).perform
  end
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode, latitude: origin_hub.latitude, longitude: origin_hub.longitude) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode, latitude: destination_hub.latitude, longitude: destination_hub.longitude) }
  let(:pickup_carta) { FactoryBot.build(:carta_result, id: "xxx1", type: "address", address: pickup_address.geocoded_address, latitude: pickup_address.latitude, longitude: pickup_address.longitude) }
  let(:delivery_carta) { FactoryBot.build(:carta_result, id: "xxx1", type: "address", address: delivery_address.geocoded_address, latitude: delivery_address.latitude, longitude: delivery_address.longitude) }
  let(:query_calculation) { FactoryBot.create(:journey_query_calculation, query: query, pre_carriage: pre_carriage, on_carriage: on_carriage, status: "queued") }
  let(:pre_carriage) { true }
  let(:on_carriage) { true }
  include_context "complete_route_with_trucking"

  before do
    FactoryBot.create(:companies_membership, client: client, company: company)
    Organizations.current_id = organization.id
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination)
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
  end

  describe "#perform" do
    context "with single trucking Availability" do
      it "returns a single valid result for the door to door request" do
        expect(results.length).to eq(1)
      end
    end

    context "when pre and on carriage are disabled but params are configured for pre and on carriage" do
      let(:pre_carriage) { false }
      let(:on_carriage) { false }

      it "returns a single valid result for the port to port request", :aggregate_failures do
        expect(results).to be_nil
        expect(query_calculation.reload.status).to eq("failed")
        expect(query_calculation.journey_errors.first.code).to eq(1008)
      end
    end

    context "when origin/destination params are not configured for pre or on carriage, but fall in trucking zones" do
      let(:params) do
        FactoryBot.build(:journey_request_params,
          origin: origin,
          destination: destination,
          origin_hub: origin_hub,
          destination_hub: destination_hub,
          direction: "export",
          load_type: load_type,
          async: true,
          selected_day: 4.days.from_now.beginning_of_day.to_s,
          container_attributes: container_attributes)
      end

      it "returns a single valid result for a door to door request, despite being provided LOCODES" do
        expect(results.length).to eq(1)
      end

      context "when origin/destination params are not configured for pre or on carriage and neither is service" do
        let(:pre_carriage) { false }
        let(:on_carriage) { false }

        it "returns a single valid result for a port to port request" do
          expect(results.length).to eq(1)
        end
      end
    end

    context "with multiple trucking Availability" do
      before do
        cargo_classes.each do |cargo_class|
          FactoryBot.create(:trucking_with_unit_rates,
            hub: origin_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: "container",
            truck_type: "chassis",
            tenant_vehicle: trucking_tenant_vehicle_2,
            location: pickup_trucking_location)
          FactoryBot.create(:trucking_with_unit_rates,
            hub: destination_hub,
            organization: organization,
            cargo_class: cargo_class,
            load_type: "container",
            truck_type: "chassis",
            tenant_vehicle: trucking_tenant_vehicle_2,
            location: delivery_trucking_location,
            carriage: "on")
        end
        FactoryBot.create(:routing_carrier, name: trucking_tenant_vehicle_2.carrier.name, code: trucking_tenant_vehicle_2.carrier.code)
      end

      let(:trucking_tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "trucking_2") }
      let(:desired_tenant_vehicle_combos) do
        [
          [tenant_vehicle.id, tenant_vehicle.id, tenant_vehicle.id],
          [tenant_vehicle.id, tenant_vehicle.id, trucking_tenant_vehicle_2.id],
          [trucking_tenant_vehicle_2.id, tenant_vehicle.id, tenant_vehicle.id],
          [trucking_tenant_vehicle_2.id, tenant_vehicle.id, trucking_tenant_vehicle_2.id]
        ]
      end

      it "returns multiple results for a path when multiple trucking options exist on both sides" do
        expect(results.length).to eq(4)
      end
    end
  end
end
