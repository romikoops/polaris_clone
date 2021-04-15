# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe CargoUnit, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_cargo_unit)).to be_valid
    end

    it "rejects an invalid cargo class" do
      expect(FactoryBot.build(:journey_cargo_unit, cargo_class: "cargo_item")).not_to be_valid
    end

    describe ".volume" do
      context "when it is an individual cargo item" do
        let(:unit) { FactoryBot.build(:journey_cargo_unit) }
        let(:expected_value) do
          Measured::Volume.new(unit.width_value * unit.length_value * unit.height_value, "m3")
        end

        it "returns the correct volume of the item" do
          expect(unit.volume).to eq(expected_value)
        end
      end

      context "when it is an container" do
        let(:unit) { FactoryBot.build(:journey_cargo_unit, :fcl) }

        it "returns the correct volume of the item" do
          expect(unit.volume).to be_nil
        end
      end
    end
  end
end
