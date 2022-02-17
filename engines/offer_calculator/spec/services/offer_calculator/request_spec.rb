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
  let(:query) { FactoryBot.create(:journey_query) }
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
end
