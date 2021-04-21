# frozen_string_literal: true

require "spec_helper"

RSpec.describe CargoPacker::SpaceBreaker do
  let(:spaces) { described_class.new(space: space, placement: placement).perform }
  let(:item) do
    CargoPacker::Item.new(
      dimensions: CargoPacker::Dimensions.new(
        width: 1.2,
        length: 0.8,
        height: 1.2
      ),
      weight: 100,
      stackable: true
    )
  end
  let(:placement) do
    CargoPacker::Placement.new(
      dimensions: item.dimensions,
      position: CargoPacker::Position.new(
        width: 0.0,
        length: 0.0,
        height: 0.0
      ),
      item: item,
      stackable: true
    )
  end
  let(:space) do
    CargoPacker::Space.new(
      dimensions: CargoPacker::Dimensions.new(
        width: 2.4,
        length: 7,
        height: 2.6
      ),
      position: CargoPacker::Position.new(
        width: 0.0,
        length: 0.0,
        height: 0.0
      )
    )
  end
  let(:space_right) { spaces[0] }
  let(:space_up) { spaces[1] }
  let(:space_front) { spaces[2] }

  describe ".perform" do
    it "breaks the space up to the right", :aggregate_failures do
      expect(space_right.width).to eq(space.width - placement.width)
      expect(space_right.position.width).to eq(space.position.width + placement.width)
    end

    it "breaks the space up above the box", :aggregate_failures do
      expect(space_up.height).to eq(space.height - placement.height)
      expect(space_up.position.height).to eq(space.position.height + placement.height)
    end

    it "breaks the space up in front of the box", :aggregate_failures do
      expect(space_front.length).to eq(space.length - placement.length)
      expect(space_front.position.length).to eq(space.position.length + placement.length)
    end
  end
end
