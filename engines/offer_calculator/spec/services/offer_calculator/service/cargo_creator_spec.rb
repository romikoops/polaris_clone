# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::CargoCreator do
  let(:cargo_creator) { described_class.new(query: query, params: params, persist: false) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:query) { FactoryBot.create(:journey_query, cargo_units: []) }
  describe "perform" do
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
        {"cargo_items_attributes" => [
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
      let(:first_param) { params.dig("cargo_items_attributes", 0) }

      it "creates one fcl_20 item" do
        expect(item.cargo_class).to eq("fcl_20")
        expect(item.weight).to eq(Measured::Weight.new(first_param.dig("payload_in_kg"), "kg"))
      end
    end
  end
end
