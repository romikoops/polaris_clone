# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ValidationContract do
  describe "#call" do
    let(:parent_id) { nil }
    let(:origin_id) { "aaaa" }
    let(:destination_id) { "bbbb" }
    let(:id) { SecureRandom.uuid }
    let(:items) do
      [
        {
          id: id,
          cargoClass: "lcl",
          stackable: true,
          colliType: "pallet",
          quantity: 1,
          length: 120,
          width: 100,
          height: 120,
          weight: 1200,
          commodities: []
        }
      ]
    end
    let(:cargo_classes) { ["lcl"] }
    let(:load_type) { "cargo_item" }
    let(:types) { ["cargo_item"] }
    let(:cargo_ready_date) { Time.zone.tomorrow }
    let(:params) do
      {
        types: types,
        items: items,
        loadType: load_type,
        originId: origin_id,
        destinationId: destination_id
      }
    end
    let(:result) { described_class.new.call(params) }

    shared_examples_for "valid params" do
      it "returns no errors" do
        expect(result.errors.to_h).to be_empty
      end
    end

    context "when lcl and valid" do
      it_behaves_like "valid params"
    end

    context "when fcl_20" do
      let(:items) do
        [
          {
            id: id,
            cargoClass: "fcl_20",
            quantity: 1,
            weight: 1200,
            commodities: []
          }
        ]
      end
      let(:load_type) { "container" }

      it_behaves_like "valid params"
    end

    context "when aggregated_lcl" do
      let(:items) do
        [
          {
            id: id,
            cargoClass: "aggregated_lcl",
            weight: 1200,
            volume: 0.05
          }
        ]
      end

      it_behaves_like "valid params"
    end

    context "when items are empty" do
      let(:items) { [] }

      it "returns errors indicating Items are needed" do
        expect(result.errors.to_h).to eq({ items: ["must be present"] })
      end
    end

    context "when types are empty" do
      let(:types) { [] }

      it "returns errors indicating Types are needed" do
        expect(result.errors.to_h).to eq({ types: ["must be present"] })
      end
    end

    context "when types includes 'routing'" do
      let(:types) { ["routing"] }

      it "returns no errors" do
        expect(result.errors.to_h).to eq({})
      end
    end

    context "when types are invalid" do
      let(:types) { ["blue"] }

      it "returns errors indicating the Type was invalid" do
        expect(result.errors.to_h).to eq({ types: ["must be one of cargo_item | routing"] })
      end
    end

    context "when item is missing cargo class" do
      let(:items) do
        [
          {
            id: SecureRandom.uuid,
            cargoClass: nil,
            quantity: 1,
            weight: 1200,
            commodities: []
          }
        ]
      end

      it "returns errors indicating Items require cargoClasses" do
        expect(result.errors.to_h).to eq({ items: { 0 => { cargoClass: ["must be filled"] } } })
      end
    end

    context "when loadType is invalid" do
      let(:load_type) { "blue" }

      it "returns errors indicating cargoReadyDate mus be in the future" do
        expect(result.errors.to_h).to eq({ loadType: ["must be one of cargo_item | container"] })
      end
    end

    context "when item is missing an id" do
      let(:items) do
        [
          {
            id: nil,
            cargoClass: "fcl_20",
            quantity: 1,
            weight: 120,
            commodities: []
          }
        ]
      end

      it "returns errors indicating Items require an Id" do
        expect(result.errors.to_h).to eq({ items: { 0 => { id: ["must be a string"] } } })
      end
    end

    context "when item only has the weight provided" do
      let(:items) do
        [
          {
            id: id,
            cargoClass: "lcl",
            stackable: true,
            colliType: "pallet",
            quantity: 1,
            length: 0,
            width: 0,
            height: 0,
            weight: 1200,
            commodities: []
          }
        ]
      end

      it "returns no errors" do
        expect(result.errors.to_h).to be_empty
      end
    end
  end
end
