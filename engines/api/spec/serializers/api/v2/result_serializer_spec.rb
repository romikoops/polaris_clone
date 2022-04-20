# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ResultSerializer do
    let(:journey_query) { FactoryBot.create(:journey_query) }
    let(:result) { FactoryBot.create(:journey_result, query_id: journey_query.id) }
    let(:decorated_result) { Api::V2::ResultDecorator.new(result) }
    let(:serialized_result) { described_class.new(decorated_result).serializable_hash }
    let(:target) { serialized_result.dig(:data, :attributes) }
    let(:routing_carrier) { FactoryBot.create(:routing_carrier) }

    before { allow(decorated_result).to receive(:routing_carrier).and_return(routing_carrier) }

    it "returns the correct modes of transport for the object passed" do
      expect(target[:modesOfTransport]).to eq(["ocean"])
    end

    it "returns the carrier logo" do
      expect(target[:carrierLogo]).to include(routing_carrier.logo.filename.to_s)
    end

    it "returns the transshipment" do
      expect(target[:transshipment]).to eq(decorated_result.main_freight_section.transshipment)
    end

    it "returns the number of stops" do
      expect(target[:numberOfStops]).to eq(0)
    end

    it "validates queryId is present in the serialized attributes" do
      expect(target[:queryId]).to be_present
    end

    it "returns preCarriage as false when there is no Pre-carriage" do
      expect(target[:preCarriage]).to eq(false)
    end

    it "returns onCarriage as false when there is no On-carriage" do
      expect(target[:onCarriage]).to eq(false)
    end

    context "when Result has Pre-carriage and On-carriage" do
      let(:result) do
        FactoryBot.create(:journey_result,
          query_id: journey_query.id,
          route_sections: [
            FactoryBot.build(:journey_route_section, :pre_carriage),
            FactoryBot.build(:journey_route_section, :main_carriage),
            FactoryBot.build(:journey_route_section, :on_carriage)
          ])
      end

      it "returns preCarriage as true when there is Pre-carriage" do
        expect(target[:preCarriage]).to eq(true)
      end

      it "returns onCarriage as true when there is On-carriage" do
        expect(target[:onCarriage]).to eq(true)
      end
    end

    context "when the result decorator's total returns nil" do
      it "returns nil values for a money representation" do
        allow(decorated_result).to receive(:total).and_return(nil)
        expect(target[:total]).to eq({ value: nil, currency: nil })
      end
    end

    it "returns a money representation when the total is present" do
      expect(target[:total]).to eq({ value: 36.00, currency: "EUR" })
    end

    context "when origin and destination have terminal information" do
      let(:result) do
        FactoryBot.create(:journey_result,
          query_id: journey_query.id,
          route_sections: [
            FactoryBot.build(:journey_route_section,
              :main_carriage,
              from: FactoryBot.build(:journey_route_point, name: "Hamburg", locode: "DEHAM", terminal: "A-1"),
              to: FactoryBot.build(:journey_route_point, name: "Shanghai", locode: "CNSGH", terminal: "B-2"))
          ])
      end

      it "returns name as the origin" do
        expect(target[:origin]).to eq("Hamburg")
      end

      it "returns name as the destination" do
        expect(target[:destination]).to eq("Shanghai")
      end

      it "returns terminal of the origin" do
        expect(target[:originTerminal]).to eq("A-1")
      end

      it "returns terminal of the destination" do
        expect(target[:destinationTerminal]).to eq("B-2")
      end
    end

    context "when origin is an address (pre-carriage) and destination is a hub without terminal information" do
      let(:result) do
        FactoryBot.create(:journey_result,
          query_id: journey_query.id,
          route_sections: [
            FactoryBot.build(:journey_route_section,
              :main_carriage,
              from: FactoryBot.build(:journey_route_point, :address, name: "Brooktorkai 7"),
              to: FactoryBot.build(:journey_route_point, name: "Shanghai", locode: "CNSGH"))
          ])
      end

      it "returns address as the origin" do
        expect(target[:origin]).to eq("Brooktorkai 7")
      end

      it "returns name as the destination" do
        expect(target[:destination]).to eq("Shanghai")
      end
    end
  end
end
