# frozen_string_literal: true

require "spec_helper"

RSpec.describe CargoPacker::Packer do
  let(:packing) { described_class.pack(container: container, items: items) }
  let(:container) do
    CargoPacker::Container.new(
      dimensions: CargoPacker::Dimensions.new(
        width: 0.8,
        length: 7,
        height: 2.6
      ),
      load_meterage_divisor: 2.4
    )
  end
  let(:items) do
    [
      CargoPacker::Item.new(
        dimensions: CargoPacker::Dimensions.new(
          width: 0.8,
          length: 1.2,
          height: 1
        ),
        weight: 500,
        stackable: stackable
      ),
      CargoPacker::Item.new(
        dimensions: CargoPacker::Dimensions.new(
          width: 0.8,
          length: 1.2,
          height: 1.2
        ),
        weight: 500,
        stackable: stackable
      ),
      CargoPacker::Item.new(
        dimensions: CargoPacker::Dimensions.new(
          width: 0.8,
          length: 1.2,
          height: 1.4
        ),
        weight: 600,
        stackable: stackable
      ),
      CargoPacker::Item.new(
        dimensions: CargoPacker::Dimensions.new(
          width: 0.8,
          length: 1.2,
          height: 0.5
        ),
        weight: 500,
        stackable: stackable
      )
    ]
  end

  describe ".perform" do
    context "with stackable items" do
      let(:stackable) { true }

      it "packs the items" do
        expect(packing.load_meters).to eq(0.8)
      end
    end

    context "with non stackable items" do
      let(:stackable) { false }

      it "packs the items" do
        expect(packing.load_meters).to eq(1.6)
      end
    end
  end
end
