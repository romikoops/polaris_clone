# frozen_string_literal: true

require "spec_helper"

RSpec.describe CargoPacker::SpaceCombiner do
  let(:combined_spaces) { described_class.new(spaces: spaces).perform }
  let(:spaces) do
    [
      CargoPacker::Space.new(
        dimensions: CargoPacker::Dimensions.new(
          width: 1.1,
          length: 0.7,
          height: 0.4
        ),
        position: CargoPacker::Position.new(
          width: 0.0,
          length: 0.0,
          height: 0.0
        )
      ),
      other_space
    ]
  end

  describe ".perform" do
    context "when adjacent to the left" do
      let(:other_space) do
        CargoPacker::Space.new(
          dimensions: CargoPacker::Dimensions.new(
            width: 0.4,
            length: 0.7,
            height: 0.4
          ),
          position: CargoPacker::Position.new(
            width: 1.1,
            length: 0.0,
            height: 0.0
          )
        )
      end

      it "combines the spaces that have complete and adjacent sides", :aggregate_failures do
        expect(combined_spaces.length).to eq(1)
        expect(combined_spaces.first.dimensions.width).to eq(spaces.sum { |space| space.dimensions.width })
        expect(combined_spaces.first.dimensions.length).to eq(spaces.first.dimensions.length)
      end
    end

    context "when adjacent to the front" do
      let(:other_space) do
        CargoPacker::Space.new(
          dimensions: CargoPacker::Dimensions.new(
            width: 1.1,
            length: 0.7,
            height: 0.4
          ),
          position: CargoPacker::Position.new(
            width: 0.0,
            length: 0.7,
            height: 0.0
          )
        )
      end

      it "combines the spaces that have complete and adjacent sides", :aggregate_failures do
        expect(combined_spaces.length).to eq(1)
        expect(combined_spaces.first.dimensions.length).to eq(spaces.sum { |space| space.dimensions.length })
        expect(combined_spaces.first.dimensions.width).to eq(spaces.first.dimensions.width)
      end
    end
  end
end
