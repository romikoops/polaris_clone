# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::QueryParamsContract do
  describe "#call" do
    let(:parent_id) { nil }
    let(:origin_id) { "aaaa" }
    let(:destination_id) { "bbbb" }
    let(:items) do
      [
        {
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
    let(:params) do
      {
        items: items,
        loadType: load_type,
        cargoReadyDate: Time.zone.tomorrow.to_s,
        parentId: parent_id,
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
            cargoClass: "aggregated_lcl",
            weight: 1200,
            volume: 0.05
          }
        ]
      end

      it_behaves_like "valid params"
    end

    context "when parent_id is part of params" do
      let(:parent_id) { SecureRandom.uuid }

      it_behaves_like "valid params"
    end

    context "when items are empty" do
      let(:items) { [] }

      it "returns errors indicating Items are needed" do
        expect(result.errors.to_h).to eq({ items: ["must be present"] })
      end
    end

    context "when item is missing cargo class" do
      let(:items) do
        [
          {
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

    context "when items weight is zero" do
      let(:items) do
        [
          {
            cargoClass: "fcl_20",
            quantity: 1,
            weight: 0,
            commodities: []
          }
        ]
      end

      it "returns errors indicating Items require non zero weights" do
        expect(result.errors.to_h).to eq({ items: { 0 => { weight: ["must be greater than 0"] } } })
      end
    end
  end
end
