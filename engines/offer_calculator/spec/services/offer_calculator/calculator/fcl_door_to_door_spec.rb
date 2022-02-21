# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Calculator do
  let(:cargo_classes) { %w[fcl_20 fcl_40 fcl_40_hq] }
  let(:load_type) { "container" }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:source) { FactoryBot.create(:application) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      load_type: "container",
      destination_hub: nil,
      origin_hub: nil,
      desired_start_date: Time.zone.today + 4.days,
      user: user,
      trucking: {
        pre_carriage: {
          address_id: pickup_address.id,
          truck_type: "chassis"
        },
        on_carriage: {
          address_id: delivery_address.id,
          truck_type: "chassis"
        }
      },
      organization: organization)
  end
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
      pickup_truck_type: "chassis",
      delivery_address: delivery_address,
      delivery_truck_type: "chassis",
      pickup_address: pickup_address,
      direction: "export",
      load_type: load_type,
      selected_day: 4.days.from_now.beginning_of_day.to_s,
      container_attributes: container_attributes)
  end
  let(:origin_address_params) do
    {
      latitude: pickup_address.latitude,
      longitude: pickup_address.longitude,
      zip_code: pickup_address.zip_code,
      country: pickup_address.country.name,
      geocoded_address: pickup_address.geocoded_address,
      street_number: pickup_address.street_number
    }.with_indifferent_access
  end
  let(:destination_address_params) do
    {
      latitude: delivery_address.latitude,
      longitude: delivery_address.longitude,
      zip_code: delivery_address.zip_code,
      country: delivery_address.country.name,
      geocoded_address: delivery_address.geocoded_address,
      street_number: delivery_address.street_number
    }.with_indifferent_access
  end
  let(:creator) { FactoryBot.create(:users_client, organization: organization) }
  let(:query) do
    described_class.new(
      params: params,
      client: user,
      source: source,
      creator: creator
    ).perform
  end
  let(:results) { query.results }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }

  include_context "complete_route_with_trucking"

  before do
    FactoryBot.create(:companies_membership, client: user)
    Organizations.current_id = organization.id
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination)
    allow(Carta::Client).to receive(:reverse_geocode).with(latitude: pickup_address.latitude, longitude: pickup_address.longitude).and_return(origin)
    allow(Carta::Client).to receive(:reverse_geocode).with(latitude: delivery_address.latitude, longitude: delivery_address.longitude).and_return(destination)
    allow_any_instance_of(OfferCalculator::Service::ScheduleFinder).to receive(:longest_trucking_time).and_return(10)
  end

  describe ".perform" do
    context "with single trucking Availability" do
      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(1)
        end
      end
    end

    context "with offer creator errors with a blacklisted user" do
      before do
        organization.scope.update(content: { blacklisted_emails: [creator.email] })
      end

      it "set the Query billable as false" do
        aggregate_failures do
          expect(query.status).to eq("completed")
          expect(query.billable).to be(false)
        end
      end
    end

    context "when carta service is unavailable" do
      before do
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: pickup_address.latitude, longitude: pickup_address.longitude).and_raise(Carta::Client::ServiceUnavailable)
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: delivery_address.latitude, longitude: delivery_address.longitude).and_raise(Carta::Client::ServiceUnavailable)
      end

      it "raises OfferBuilder exception" do
        expect { results }.to raise_error(OfferCalculator::Errors::OfferBuilder)
      end
    end

    context "when carta service cannot find the location" do
      before do
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: pickup_address.latitude, longitude: pickup_address.longitude).and_raise(Carta::Client::LocationNotFound)
        allow(Carta::Client).to receive(:reverse_geocode).with(latitude: delivery_address.latitude, longitude: delivery_address.longitude).and_raise(Carta::Client::LocationNotFound)
      end

      it "raises OfferBuilder exception" do
        expect { results }.to raise_error(OfferCalculator::Errors::LocationNotFound)
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

      it "perform a booking calulation" do
        aggregate_failures do
          expect(results.length).to eq(4)
        end
      end
    end
  end
end
