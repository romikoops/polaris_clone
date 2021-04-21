# frozen_string_literal: true

require "spec_helper"

RSpec.describe CargoPacker::Service do
  let(:result) { described_class.pack(items: items, options: options) }
  let(:options) do
    {
      height_limit: 2.2,
      load_meterage_divisor: 2.4
    }
  end

  describe ".perform" do
    shared_examples_for "packing load_meters" do
      it "calculates the correct load meters for the items" do
        expect(result.load_meters).to eq(expected_load_meters)
      end
    end

    context "when case 1" do
      let(:items) { FactoryBot.build(:cargo_packer_items, :case1) }
      let(:expected_load_meters) { 5.45 }

      it_behaves_like "packing load_meters"
    end

    context "when case 2" do
      let(:items) { FactoryBot.build(:cargo_packer_items, :case2) }
      let(:expected_load_meters) { 2.8 }

      it_behaves_like "packing load_meters"
    end

    context "when case 3" do
      let(:items) { FactoryBot.build(:cargo_packer_items, :case3) }
      let(:expected_load_meters) { 0.4 }

      it_behaves_like "packing load_meters"
    end

    context "when case 4" do
      let(:items) { FactoryBot.build(:cargo_packer_items, :case4) }
      let(:expected_load_meters) { 4.4333 }

      it_behaves_like "packing load_meters"
    end

    context "when no valid packing can be found" do
      let(:items) do
        [
          {
            quantity: 2,
            weight: 100,
            height: 2.4,
            width: 20,
            length: 5,
            stackable: true
          }
        ]
      end

      it "raises an error when the items are too big to be packed" do
        expect { result }.to raise_error(CargoPacker::Errors::PackingFailed)
      end
    end
  end
end
