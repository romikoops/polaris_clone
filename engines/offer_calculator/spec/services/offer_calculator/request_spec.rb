# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Request do
  let(:params) do
    FactoryBot.build(:journey_request_params,
      :lcl,
      pickup_address: pickup_address,
      delivery_address: delivery_address,
      origin_hub: origin_hub,
      destination_hub: destination_hub)
  end
  let(:pickup_address) { nil }
  let(:delivery_address) { nil }
  let(:origin_hub) { nil }
  let(:destination_hub) { nil }
  let(:query) { FactoryBot.create(:journey_query, cargo_count: 0) }
  let(:persist) { false }
  let(:request) { described_class.new(query: query, params: params, persist: persist, pre_carriage: pre_carriage, on_carriage: on_carriage) }
  let(:pre_carriage) { true }
  let(:on_carriage) { true }

  before do
    Geocoder::Lookup::Test.add_stub([query.destination_coordinates.y, query.destination_coordinates.x], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Shanghai, China",
      "city" => "Shanghai",
      "country" => "China",
      "country_code" => "CN",
      "postal_code" => "210001"
    ])
    Geocoder::Lookup::Test.add_stub([query.origin_coordinates.y, query.origin_coordinates.x], [
      "address_components" => [{ "types" => ["premise"] }],
      "address" => "Hamburg, Germany",
      "city" => "Hamburg",
      "country" => "Germany",
      "country_code" => "DE",
      "postal_code" => "20457"
    ])
  end

  describe "#load_type" do
    it "returns the load_type" do
      expect(request.load_type).to eq("cargo_item")
    end
  end

  describe "#cargo_classes" do
    context "when fcl" do
      before do
        FactoryBot.create(:journey_cargo_unit, :fcl, cargo_class: "fcl_20", query: query)
        FactoryBot.create(:journey_cargo_unit, :fcl, cargo_class: "fcl_40", query: query)
        query.reload
      end

      it "returns the container cargo_classes" do
        expect(request.cargo_classes).to match_array(%w[fcl_20 fcl_40])
      end
    end

    context "when lcl" do
      before do
        FactoryBot.create(:journey_cargo_unit, query: query)
        query.reload
      end

      it "returns the cargo item cargo_class" do
        expect(request.cargo_classes).to match_array(%w[lcl])
      end
    end

    context "when aggregate_lcl" do
      before do
        FactoryBot.create(:journey_cargo_unit, :aggregate_lcl, query: query)
        query.reload
      end

      it "returns lcl as its cargo class" do
        expect(request.cargo_classes).to match_array(%w[lcl])
      end
    end
  end

  describe "#pickup_address" do
    context "when there is pre carriage" do
      let(:pickup_address) { FactoryBot.build(:legacy_address) }

      it "returns an Address when there is pre carriage" do
        expect(request.pickup_address).to be_a(Legacy::Address)
      end
    end

    context "when there is address provided but pre carriage is set to true" do
      let(:origin_hub) { FactoryBot.create(:legacy_hub) }

      it "returns an Address when there is pre carriage" do
        expect(request.pickup_address).to be_a(Legacy::Address)
      end
    end

    context "when there is address provided but pre carriage is set to false" do
      let(:pre_carriage) { false }
      let(:pickup_address) { FactoryBot.build(:legacy_address) }

      it "returns nil when pre carriage is set to false" do
        expect(request.pickup_address).to be_nil
      end
    end
  end

  describe "#delivery_address" do
    context "when there is on carriage" do
      let(:delivery_address) { FactoryBot.build(:legacy_address) }

      it "returns an Address when there is on carriage" do
        expect(request.delivery_address).to be_a(Legacy::Address)
      end
    end

    context "when there is address provided but on carriage is set" do
      let(:destination_hub) { FactoryBot.create(:legacy_hub) }

      it "returns an Address when there is on carriage" do
        expect(request.delivery_address).to be_a(Legacy::Address)
      end
    end
  end

  describe "#origin" do
    before { allow(Carta::Client).to receive(:lookup).with(id: query.origin_geo_id).and_return(origin) }

    let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode") }

    it "returns the Carta::Result object for the Location" do
      expect(request.origin).to eq(origin)
    end
  end

  describe "#destination" do
    before { allow(Carta::Client).to receive(:lookup).with(id: query.destination_geo_id).and_return(destination) }

    let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode") }

    it "returns the Carta::Result object for the Location" do
      expect(request.destination).to eq(destination)
    end
  end
end
