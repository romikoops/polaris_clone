# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::CargoCreator do
  let(:persist) { false }
  let(:cargo_creator) { described_class.new(query: query, params: params, persist: persist) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:query) { FactoryBot.create(:journey_query, cargo_units: []) }

  describe "perform" do
    context "legacy" do
      context "when lcl" do
        let(:params) do
          {"cargo_items_attributes" => [
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
          ]}
        end
        let(:results) { cargo_creator.perform }
        let(:item) { results.first }
        let(:first_param) { params.dig("cargo_items_attributes", 0) }

        it "creates one lcl item" do
          expect(item.width).to eq(Measured::Length.new(first_param.dig("width"), "cm"))
          expect(item.length).to eq(Measured::Length.new(first_param.dig("length"), "cm"))
          expect(item.height).to eq(Measured::Length.new(first_param.dig("height"), "cm"))
          expect(item.weight).to eq(Measured::Weight.new(first_param.dig("payload_in_kg"), "kg"))
        end
      end

      context "when fcl" do
        let(:params) do
          {"containers_attributes" => [
            {
              "payload_in_kg" => 120,
              "size_class" => "fcl_20",
              "dangerous_goods" => false,
              "stackable" => true
            }
          ]}
        end
        let(:results) { cargo_creator.perform }
        let(:item) { results.first }
        let(:first_param) { params.dig("containers_attributes", 0) }

        it "creates one fcl_20 item" do
          expect(item.cargo_class).to eq("fcl_20")
          expect(item.weight).to eq(Measured::Weight.new(first_param.dig("payload_in_kg"), "kg"))
        end
      end

      context "when aggregated_lcl" do
        let(:params) do
          {
            "aggregated_cargo_attributes" => {
              "weight" => 120,
              "volume" => 1
            }
          }
        end
        let(:results) { cargo_creator.perform }
        let(:item) { results.first }
        let(:first_param) { params.dig("aggregated_cargo_attributes") }

        it "creates one aggregated item" do
          expect(item.cargo_class).to eq("aggregated_lcl")
          expect(item.weight).to eq(Measured::Weight.new(first_param.dig("weight"), "kg"))
        end
      end
    end

    context 'greenland' do
      context "when lcl" do
        let(:params) do
          {"cargo_items_attributes" => [
            {
              "payload_in_kg" => 120,
              "width" => 120,
              "length" => 80,
              "height" => 120,
              "quantity" => 1,
              "colli_type" => 'pallet',
              "cargo_class" => 'lcl',
              "dangerous_goods" => false,
              "stackable" => true
            }
          ]}
        end
        let(:results) { cargo_creator.perform }
        let(:item) { results.first }
        let(:first_param) { params.dig("cargo_items_attributes", 0) }

        it "creates one lcl item" do
          expect(item.width).to eq(Measured::Length.new(first_param.dig("width"), "cm"))
          expect(item.length).to eq(Measured::Length.new(first_param.dig("length"), "cm"))
          expect(item.height).to eq(Measured::Length.new(first_param.dig("height"), "cm"))
          expect(item.weight).to eq(Measured::Weight.new(first_param.dig("payload_in_kg"), "kg"))
        end
      end

      context "when fcl" do
        let(:params) do
          {"containers_attributes" => [
            {
              "payload_in_kg" => 120,
              "cargo_class" => "fcl_20",
              "dangerous_goods" => false,
              "stackable" => true
            }
          ]}
        end
        let(:results) { cargo_creator.perform }
        let(:item) { results.first }
        let(:first_param) { params.dig("containers_attributes", 0) }

        it "creates one fcl_20 item" do
          expect(item.cargo_class).to eq("fcl_20")
          expect(item.weight).to eq(Measured::Weight.new(first_param.dig("payload_in_kg"), "kg"))
        end
      end

      context "when aggregated_lcl" do
        let(:params) do
          {
            "aggregated_cargo_attributes" => {
              "weight" => 120,
              "volume" => 1,
              "commodities" => [{
                "imo_class" => "0",
                "description" => "Unknown IMO Class"
              }],
            }
          }
        end
        let(:results) { cargo_creator.perform }
        let(:item) { results.first }
        let(:first_param) { params.dig("aggregated_cargo_attributes") }

        it "creates one aggregated item" do
          expect(item.cargo_class).to eq("aggregated_lcl")
          expect(item.weight).to eq(Measured::Weight.new(first_param.dig("weight"), "kg"))
        end
      end
    end

    context "when dangerous goods is expressed as CommodityInfo" do
      let(:params) do
        {"cargo_items_attributes" => [
          {
            "payload_in_kg" => 121,
            "total_volume" => 0,
            "total_weight" => 0,
            "width" => 130,
            "length" => 100,
            "height" => 100,
            "quantity" => 2,
            "colli_type" => "pallet",
            "commodities" => [{
              "imo_class" => "0",
              "description" => "Unknown IMO Class"
            }],
            "stackable" => true
          }
        ]}
      end
      let(:results) { cargo_creator.perform }
      let(:item) { results.first }
      let(:commodity_info) { item.commodity_infos.first }
      let(:first_param) { params.dig("cargo_items_attributes", 0) }
      let(:persist) { true }

      it "creates the CommodityInfo for the IMO Class", :aggregate_failures do
        expect(commodity_info.imo_class).to eq("0")
        expect(commodity_info.description).to eq("Unknown IMO Class")
      end
    end
  end
end
