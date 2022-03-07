# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::CargoUnitDecorator do
  let(:decorated_cargo) { described_class.new(cargo_unit) }
  let(:cargo_unit) { FactoryBot.create(:journey_cargo_unit) }

  context "when the cargo unit is lcl" do
    describe "#dimensions" do
      let(:expected_string) { "0.80 m x 1.20 m x 1.40 m (LxWxH) @ 3000.00 kg" }

      it "returns the dimensions joined together" do
        expect(decorated_cargo.dimensions).to eq(expected_string)
      end
    end

    describe "#cargo_type" do
      it "returns the colli type" do
        expect(decorated_cargo.cargo_type).to eq("Pallet")
      end
    end
  end

  context "when the cargo unit is aggregate_lcl" do
    let(:cargo_unit) { FactoryBot.create(:journey_cargo_unit, :aggregate_lcl) }

    describe "#dimensions" do
      let(:expected_string) { "1.30 m3 @ 3000.00 kg" }

      it "returns the dimensions joined together" do
        expect(decorated_cargo.dimensions).to eq(expected_string)
      end
    end

    describe "#cargo_type" do
      it "returns the a string indicating this is aggregated cargo" do
        expect(decorated_cargo.cargo_type).to eq("Aggregated LCL")
      end
    end
  end

  context "when the cargo unit is fcl" do
    let(:cargo_unit) { FactoryBot.create(:journey_cargo_unit, :fcl) }

    describe "#dimensions" do
      it "returns nil as containers are standardised" do
        expect(decorated_cargo.dimensions).to eq("@ 3000.00 kg")
      end
    end

    describe "#cargo_type" do
      it "returns the container type" do
        expect(decorated_cargo.cargo_type).to eq("FCL 20")
      end
    end
  end

  describe "#imo_classes" do
    let!(:imo_class) { FactoryBot.create(:journey_commodity_info, cargo_unit: cargo_unit, imo_class: "1.1") }

    it "returns all related CommodityInfo instances with imo_class present" do
      expect(decorated_cargo.imo_classes).to eq([imo_class])
    end
  end

  describe "#commodity_codes" do
    let!(:commodity_code) { FactoryBot.create(:journey_commodity_info, cargo_unit: cargo_unit, hs_code: "221.1443.2536") }

    it "returns all related CommodityInfo instances with hs_code present" do
      expect(decorated_cargo.commodity_codes).to eq([commodity_code])
    end
  end
end
