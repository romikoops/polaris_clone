# frozen_string_literal: true

require "rails_helper"
RSpec.shared_examples "CargoCreator lcl" do
  it "creates one lcl item", :aggregate_failures do
    expect(item.width).to eq(Measured::Length.new(cargo_items_attributes.dig(0, "width"), "cm"))
    expect(item.length).to eq(Measured::Length.new(cargo_items_attributes.dig(0, "length"), "cm"))
    expect(item.height).to eq(Measured::Length.new(cargo_items_attributes.dig(0, "height"), "cm"))
    expect(item.weight).to eq(Measured::Weight.new(cargo_items_attributes.dig(0, "payload_in_kg"), "kg"))
  end
end

RSpec.shared_examples "CargoCreator fcl" do
  it "creates one fcl_20 item", :aggregate_failures do
    expect(item.cargo_class).to eq("fcl_20")
    expect(item.weight).to eq(Measured::Weight.new(containers_attributes.dig(0, "payload_in_kg"), "kg"))
  end
end

RSpec.describe OfferCalculator::Service::CargoCreator do
  let(:persist) { true }
  let(:cargo_creator) { described_class.new(query: query, params: params, persist: persist) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:query) { FactoryBot.create(:journey_query, cargo_units: []) }
  let(:results) { cargo_creator.perform }
  let(:item) { results.first }
  let(:cargo_items_attributes) { [] }
  let(:containers_attributes) { [] }
  let(:aggregated_cargo_attributes) { {} }
  let(:params) do
    {
      "cargo_items_attributes" => cargo_items_attributes,
      "containers_attributes" => containers_attributes,
      "aggregated_cargo_attributes" => aggregated_cargo_attributes
    }
  end

  describe "perform (legacy)" do
    context "when lcl" do
      let(:cargo_items_attributes) do
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
      let(:first_param) { cargo_items_attributes.first }

      include_examples "CargoCreator lcl"
    end

    context "when fcl" do
      let(:containers_attributes) do
        [
          {
            "payload_in_kg" => 120,
            "size_class" => "fcl_20",
            "dangerous_goods" => false,
            "stackable" => true
          }
        ]
      end

      include_examples "CargoCreator fcl"
    end

    context "when aggregated_lcl" do
      let(:aggregated_cargo_attributes) do
        {
          "weight" => 120,
          "volume" => 1
        }
      end

      it "creates one aggregated item", :aggregate_failures do
        expect(item.cargo_class).to eq("aggregated_lcl")
        expect(item.weight).to eq(Measured::Weight.new(aggregated_cargo_attributes["weight"], "kg"))
      end
    end
  end

  describe "perform (greenland)" do
    context "when lcl" do
      let(:cargo_items_attributes) do
        [
          {
            "payload_in_kg" => 120,
            "width" => 120,
            "length" => 80,
            "height" => 120,
            "quantity" => 1,
            "colli_type" => "pallet",
            "cargo_class" => "lcl",
            "stackable" => true,
            "commodities" => []
          }
        ]
      end

      include_examples "CargoCreator lcl"
    end

    context "when fcl" do
      let(:containers_attributes) do
        [
          {
            "payload_in_kg" => 120,
            "cargo_class" => "fcl_20",
            "commodities" => [],
            "stackable" => true
          }
        ]
      end

      include_examples "CargoCreator fcl"
    end

    context "when aggregated_lcl" do
      let(:aggregated_cargo_attributes) do
        {
          "weight" => 120,
          "volume" => 1,
          "commodities" => [{
            "imo_class" => "0",
            "description" => "Unknown IMO Class"
          }]
        }
      end
      let(:commodity_info) { item.commodity_infos.first }

      it "creates one aggregated item", :aggregate_failures do
        expect(item.cargo_class).to eq("aggregated_lcl")
        expect(item.weight).to eq(Measured::Weight.new(aggregated_cargo_attributes["weight"], "kg"))
        expect(commodity_info.imo_class).to eq("0")
        expect(commodity_info.description).to eq("Unknown IMO Class")
      end
    end
  end
end
