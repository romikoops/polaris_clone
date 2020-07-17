# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::ShipmentUpdateHandler do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:email) { "test@itsmycargo.example" }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization, email: email) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:scope_content) { {} }
  let(:destination_hub) { itinerary.destination_hub }
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:gothenburg_address) { FactoryBot.create(:gothenburg_address) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:base_shipment) do
    FactoryBot.create(:legacy_shipment,
      load_type: "cargo_item",
      destination_hub: nil,
      origin_hub: nil,
      user: user,
      organization: organization)
  end
  let(:quotation) { FactoryBot.create(:quotations_quotation, organization: organization, user: user, legacy_shipment_id: base_shipment.id) }
  let(:wheelhouse) { false }

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

  let(:invalid_cargo_item_attributes) do
    [
      {
        "payload_in_kg" => 0,
        "total_volume" => 4.5,
        "total_weight" => 724.0,
        "width" => 0,
        "length" => 0,
        "height" => 0,
        "quantity" => 1,
        "cargo_item_type_id" => "",
        "dangerous_goods" => false,
        "stackable" => true
      }
    ]
  end

  let(:aggregated_cargo_attributes) do
    {
      "volume" => 2.0,
      "weight" => 1000
    }
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
    {
      shipment: {
        "id" => base_shipment.id,
        "direction" => "export",
        "selected_day" => 4.days.ago.beginning_of_day.to_s,
        "cargo_items_attributes" => [],
        "containers_attributes" => [],
        "trucking" => {
          "pre_carriage" => {"truck_type" => ""},
          "on_carriage" => {"truck_type" => ""}
        },
        "incoterm" => {},
        "aggregated_cargo_attributes" => nil
      }
    }
  end

  before do
    ::Organizations.current_id = organization.id
    FactoryBot.create(:organizations_scope, target: organization, content: scope_content)
  end

  context "when port to port" do
    let(:port_to_port_params) do
      params[:shipment]["origin"] = {
        "latitude" => origin_hub.latitude,
        "longitude" => origin_hub.longitude,
        "nexus_id" => origin_hub.nexus_id,
        "nexus_name" => origin_hub.nexus.name,
        "country" => origin_hub.nexus.country.code
      }
      params[:shipment]["destination"] = {
        "latitude" => destination_hub.latitude,
        "longitude" => destination_hub.longitude,
        "nexus_id" => destination_hub.nexus_id,
        "nexus_name" => destination_hub.nexus.name,
        "country" => destination_hub.nexus.country.code
      }
      params[:shipment]["cargo_items_attributes"] = cargo_item_attributes
      ActionController::Parameters.new(params)
    end
    let(:service) { described_class.new(shipment: base_shipment, params: port_to_port_params, quotation: quotation) }

    describe ".update_nexuses" do
      it "updates the nexus" do
        service.update_nexuses
        aggregate_failures do
          expect(base_shipment.origin_nexus_id).to eq(origin_hub.nexus_id)
          expect(base_shipment.destination_nexus_id).to eq(destination_hub.nexus_id)
        end
      end
    end

    describe ".update_trucking" do
      it "updates the trucking" do
        service.update_trucking
        expect(base_shipment.trucking).to eq(
          "pre_carriage" => {"truck_type" => ""}, "on_carriage" => {"truck_type" => ""}
        )
      end
    end

    describe ".update_incoterm" do
      it "updates the incoterm" do
        service.update_incoterm
        expect(base_shipment.incoterm_id).to eq(nil)
      end
    end

    describe ".cargo_units" do
      let(:cargo_item) { base_shipment.cargo_items.first }
      let(:aggregated_cargo) { base_shipment.aggregated_cargo }

      it "creates the cargo items" do
        service.update_cargo_units
        expect(base_shipment.cargo_items.count).to eq(1)
        cargo_item = base_shipment.cargo_items.first
        expect(cargo_item.width).to eq(cargo_item_attributes.first["width"])
        expect(cargo_item.length).to eq(cargo_item_attributes.first["length"])
        expect(cargo_item.height).to eq(cargo_item_attributes.first["height"])
        expect(cargo_item.payload_in_kg).to eq(cargo_item_attributes.first["payload_in_kg"])
      end

      context "with aggregated cargo" do
        let(:agg_params) do
          agg_params = port_to_port_params.dup
          agg_params[:shipment].delete("cargo_items_attributes")
          agg_params[:shipment]["aggregated_cargo_attributes"] = aggregated_cargo_attributes
          agg_params
        end

        it "creates an aggregated_cargo" do
          agg_service = described_class.new(shipment: base_shipment, params: agg_params, quotation: quotation)
          agg_service.update_cargo_units
          aggregate_failures do
            expect(aggregated_cargo.weight).to eq(aggregated_cargo_attributes["weight"])
            expect(aggregated_cargo.volume).to eq(aggregated_cargo_attributes["volume"])
          end
        end
      end

      it "raises the proper error when cargo units are invalid" do
        invalid_params = port_to_port_params.dup
        invalid_params[:shipment][:cargo_items_attributes] = invalid_cargo_item_attributes

        agg_service = described_class.new(
          shipment: base_shipment,
          params: invalid_params,
          quotation: quotation,
          wheelhouse: wheelhouse
        )

        expect { agg_service.update_cargo_units }.to raise_error(OfferCalculator::Errors::InvalidCargoUnit)
      end
    end

    describe ".update_selected_day" do
      it "updates the desired_start_date with the minimum" do
        service.update_selected_day
        expect(base_shipment.desired_start_date).to eq(Time.zone.today.beginning_of_day)
      end
    end

    describe ".update_updated_at" do
      it "updates the desired_start_date with the minimum" do
        service.update_updated_at
        expect(base_shipment.updated_at > 2.seconds.ago).to be_truthy
      end
    end

    describe ".set_billing" do
      context "when internal" do
        let(:email) { "xxxx@internaldomain.com" }
        let(:scope_content) { {internal_domains: ["internaldomain.com"]} }

        it "updates the billing attribute when internal" do
          service.update_billing
          expect(base_shipment.billing).to eq("internal")
        end
      end

      context "when wheelhouse" do
        let(:email) { "xxxx@internaldomain.com" }
        let(:scope_content) { {internal_domains: ["internaldomain.com"]} }
        let(:wheelhouse) { true }

        it "updates the billing attribute to internal when wheelhouse" do
          service.update_billing
          expect(base_shipment.billing).to eq("internal")
        end
      end

      context "when test" do
        let(:email) { "xxxx@itsmycargo.com" }

        it "updates the billing attribute when test" do
          service.update_billing
          expect(base_shipment.billing).to eq("test")
        end
      end

      context "when external" do
        let(:email) { "xxxx@external.com" }

        it "updates the billing attribute when external" do
          service.update_billing
          expect(base_shipment.billing).to eq("external")
        end
      end
    end
  end

  context "when door to door" do
    let(:door_to_door_params) do
      params[:shipment]["origin"] = {
        "number" => gothenburg_address.street_number,
        "street" => gothenburg_address.street,
        "zip_code" => gothenburg_address.zip_code,
        "city" => gothenburg_address.city,
        "country" => gothenburg_address.country.name,
        "full_address" => gothenburg_address.geocoded_address,
        "latitude" => gothenburg_address.latitude,
        "longitude" => gothenburg_address.longitude,
        "hub_ids" => [origin_hub.id]
      }
      params[:shipment]["destination"] = {
        "number" => shanghai_address.street_number,
        "street" => shanghai_address.street,
        "zip_code" => shanghai_address.zip_code,
        "city" => shanghai_address.city,
        "country" => shanghai_address.country.name,
        "full_address" => shanghai_address.geocoded_address,
        "latitude" => shanghai_address.latitude,
        "longitude" => shanghai_address.longitude,
        "hub_ids" => [destination_hub.id]
      }
      params[:shipment]["trucking"] = {
        "pre_carriage" => {
          "truck_type" => "chassis"
        },
        "on_carriage" => {
          "truck_type" => "side_lifter"
        }
      }
      params[:shipment]["selected_day"] = 10.days.from_now.beginning_of_day.to_s
      params[:shipment]["containers_attributes"] = container_attributes
      ActionController::Parameters.new(params)
    end

    let(:service) do
      base_shipment.update(has_pre_carriage: true, has_on_carriage: true, load_type: "container")
      described_class.new(shipment: base_shipment, params: door_to_door_params, quotation: quotation)
    end

    describe ".update_nexuses" do
      it "updates the nexus" do
        service.update_nexuses
        aggregate_failures do
          expect(base_shipment.origin_nexus_id).to eq(nil)
          expect(base_shipment.destination_nexus_id).to eq(nil)
        end
      end
    end

    describe ".update_trucking" do
      it "updates the trucking" do
        service.update_trucking
        aggregate_failures do
          expect(base_shipment.trucking.dig("pre_carriage", "truck_type")).to eq("chassis")
          expect(base_shipment.trucking.dig("on_carriage", "truck_type")).to eq("side_lifter")
          expect(base_shipment.trucking.dig("pre_carriage", "address_id")).to be_a(Numeric)
          expect(base_shipment.trucking.dig("on_carriage", "address_id")).to be_a(Numeric)
        end
      end
    end

    describe ".update_incoterm" do
      it "updates the incoterm" do
        service.update_incoterm
        expect(base_shipment.incoterm_id).to eq(nil)
      end
    end

    describe ".cargo_units" do
      it "creates the containers" do
        service.update_cargo_units
        aggregate_failures do
          expect(base_shipment.containers.count).to eq(3)
          expect(base_shipment.containers.map(&:size_class)).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
        end
      end
    end

    describe ".update_selected_day" do
      it "updates the desired_start_date" do
        service.update_selected_day
        expect(base_shipment.desired_start_date).to eq(10.days.from_now.beginning_of_day)
      end
    end

    describe ".update_updated_at" do
      it "updates the shipment updated at" do
        service.update_updated_at
        expect(base_shipment.updated_at > 2.seconds.ago).to be_truthy
      end
    end

    describe ".clear_previous_itinerary" do
      it "return nil when no itinerary" do
        service.clear_previous_itinerary
        expect(base_shipment.itinerary_id).to be_nil
      end

      it "return removes itinerary and trip" do
        base_shipment.update(itinerary: itinerary, trip: trip)
        service.clear_previous_itinerary
        aggregate_failures do
          expect(base_shipment.itinerary_id).to be_nil
          expect(base_shipment.trip_id).to be_nil
        end
      end
    end

    describe ".set_trucking_nexuses" do
      before do
        service.set_trucking_nexuses(hubs: hubs)
      end

      context "with one nexus" do
        let(:nexus) { FactoryBot.create(:legacy_nexus) }
        let(:hubs) {
          {
            origin: FactoryBot.create_list(:legacy_hub, 2, organization: organization, nexus: nexus),
            destination: []
          }
        }

        it "sets the nexus id when there is only one nexus" do
          expect(base_shipment.origin_nexus_id).to eq(nexus.id)
        end
      end

      context "with more than one one nexus" do
        let(:hubs) {
          {
            origin: FactoryBot.create_list(:legacy_hub, 2, organization: organization),
            destination: []
          }
        }

        it "sets the nexus id when there is only one nexus" do
          expect(base_shipment.origin_nexus_id).to be_nil
        end
      end
    end
  end

  context "with errors" do
    describe ".update_trucking" do
      let(:pickup_params) do
        params[:shipment]["origin"] = {
          "number" => gothenburg_address.street_number,
          "street" => gothenburg_address.street,
          "zip_code" => gothenburg_address.zip_code,
          "city" => gothenburg_address.city,
          "country" => gothenburg_address.country.name,
          "full_address" => gothenburg_address.geocoded_address,
          "latitude" => gothenburg_address.latitude,
          "longitude" => gothenburg_address.longitude,
          "hub_ids" => [origin_hub.id]
        }
        params[:shipment]["trucking"] = {
          "pre_carriage" => {
            "truck_type" => "chassis"
          }
        }
        params[:shipment]["selected_day"] = 10.days.from_now.beginning_of_day.to_s
        params[:shipment]["containers_attributes"] = container_attributes
        ActionController::Parameters.new(params)
      end

      let(:pickup_service) do
        base_shipment.update(has_pre_carriage: true, load_type: "container")
        described_class.new(shipment: base_shipment, params: pickup_params, quotation: quotation)
      end
      let(:dropoff_params) do
        params[:shipment]["origin"] = {
          "latitude" => origin_hub.latitude,
          "longitude" => origin_hub.longitude,
          "nexus_id" => origin_hub.nexus_id,
          "nexus_name" => origin_hub.nexus.name,
          "country" => origin_hub.nexus.country.code
        }
        params[:shipment]["destination"] = {
          "number" => gothenburg_address.street_number,
          "street" => gothenburg_address.street,
          "zip_code" => gothenburg_address.zip_code,
          "city" => gothenburg_address.city,
          "country" => gothenburg_address.country.name,
          "full_address" => gothenburg_address.geocoded_address,
          "latitude" => gothenburg_address.latitude,
          "longitude" => gothenburg_address.longitude,
          "hub_ids" => [origin_hub.id]
        }
        params[:shipment]["trucking"] = {
          "on_carriage" => {
            "truck_type" => "chassis"
          }
        }
        params[:shipment]["selected_day"] = 10.days.from_now.beginning_of_day.to_s
        params[:shipment]["containers_attributes"] = container_attributes
        ActionController::Parameters.new(params)
      end

      let(:dropoff_service) do
        base_shipment.update(has_on_carriage: true, load_type: "container")
        described_class.new(shipment: base_shipment, params: dropoff_params, quotation: quotation)
      end

      it "raises error when the pickup addresses arent found" do
        address = instance_double("Legacy::Address")
        allow(address).to receive(:valid?).and_return(false)
        allow(Legacy::Address).to receive(:new_from_raw_params).and_return(address)

        expect { pickup_service.update_trucking }.to raise_error(OfferCalculator::Errors::InvalidPickupAddress)
      end

      it "raises error when the delivery addresses arent found" do
        address = instance_double("Legacy::Address")
        allow(address).to receive(:valid?).and_return(false)
        allow(Legacy::Address).to receive(:new_from_raw_params).and_return(address)

        expect { dropoff_service.update_trucking }.to raise_error(OfferCalculator::Errors::InvalidDeliveryAddress)
      end
    end
  end
end
