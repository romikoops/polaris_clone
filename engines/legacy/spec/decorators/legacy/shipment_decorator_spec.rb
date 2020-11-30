# frozen_string_literal: true

require "rails_helper"

RSpec.describe Legacy::ShipmentDecorator do
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let(:load_type) { "cargo_item" }
  let(:aggregated) { false }
  let(:shipment) {
    FactoryBot.create(:completed_legacy_shipment,
      itinerary: itinerary,
      load_type: load_type,
      with_aggregated_cargo: aggregated)
  }
  let(:scope) { {append_shipment_suffix: false} }
  let(:decorated_shipment) { described_class.new(shipment, context: {scope: scope}) }
  let(:address) { FactoryBot.create(:gothenburg_address) }

  describe ".origin" do
    context "without nexus" do
      before do
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(shipment).to receive(:pickup_address).and_return(address)
        allow(shipment).to receive(:origin_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.origin).to eq("#{address.country.code}-#{address&.zip_code}")
      end
    end

    context "with nexus" do
      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.origin).to eq(shipment.origin_nexus.locode)
      end
    end

    context "without nexus or postal code" do
      before do
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(shipment).to receive(:pickup_address).and_return(address)
        allow(address).to receive(:zip_code).and_return(nil)
        allow(shipment).to receive(:origin_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.origin).to eq(address.city)
      end
    end
  end

  describe ".destination" do
    context "without nexus" do
      before do
        allow(shipment).to receive(:has_on_carriage?).and_return(true)
        allow(shipment).to receive(:delivery_address).and_return(address)
        allow(shipment).to receive(:destination_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.destination).to eq("#{address.country.code}-#{address&.zip_code}")
      end
    end

    context "with nexus" do
      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.destination).to eq(shipment.destination_nexus.locode)
      end
    end

    context "without nexus or postal code" do
      before do
        allow(shipment).to receive(:has_on_carriage?).and_return(true)
        allow(shipment).to receive(:delivery_address).and_return(address)
        allow(address).to receive(:zip_code).and_return(nil)
        allow(shipment).to receive(:destination_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.destination).to eq(address.city)
      end
    end
  end

  describe ".origin_city" do
    context "without nexus" do
      before do
        allow(shipment).to receive(:has_pre_carriage?).and_return(true)
        allow(shipment).to receive(:pickup_address).and_return(address)
        allow(shipment).to receive(:origin_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.origin_city).to eq(address.city)
      end
    end

    context "with nexus" do
      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.origin_city).to eq(shipment.origin_nexus.name)
      end
    end
  end

  describe ".destination_city" do
    context "without nexus" do
      before do
        allow(shipment).to receive(:has_on_carriage?).and_return(true)
        allow(shipment).to receive(:delivery_address).and_return(address)
        allow(shipment).to receive(:destination_nexus).and_return(nil)
      end

      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.destination_city).to eq(address.city)
      end
    end

    context "with nexus" do
      it "returns the postal code when nexus is nil" do
        expect(decorated_shipment.destination_city).to eq(shipment.destination_nexus.name)
      end
    end
  end

  describe "total_weight" do
    context "when lcl" do
      it "returns the total weight of the cargo items" do
        expect(decorated_shipment.total_weight).to eq(
          shipment.cargo_items.sum { |unit| unit.payload_in_kg * unit.quantity }.to_i
        )
      end
    end

    context "when aggregate lcl" do
      let(:aggregated) { true }

      it "returns the total weight of the aggregated cargo" do
        expect(decorated_shipment.total_weight).to eq(
          shipment.aggregated_cargo.weight.to_i
        )
      end
    end

    context "when fcl" do
      let(:load_type) { "container" }

      it "returns the total weight of the containers" do
        expect(decorated_shipment.total_weight).to eq(
          shipment.containers.sum { |unit| unit.payload_in_kg * unit.quantity }.to_i
        )
      end
    end
  end

  describe "total_volume" do
    context "when lcl" do
      it "returns the total weight of the cargo items" do
        expect(decorated_shipment.total_volume).to eq(
          shipment.cargo_items.sum { |unit| unit.volume * unit.quantity }.round(2)
        )
      end
    end

    context "when aggregate lcl" do
      let(:aggregated) { true }

      it "returns the total weight of the aggregated cargo" do
        expect(decorated_shipment.total_volume).to eq(
          shipment.aggregated_cargo.volume.to_i
        )
      end
    end

    context "when fcl" do
      let(:load_type) { "container" }

      it "returns the total weight of the containers" do
        expect(decorated_shipment.total_volume).to eq(nil)
      end
    end
  end
end
