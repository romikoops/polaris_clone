# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Support::ValueKeys do
  let(:service) { described_class.new(fee: fee) }

  describe "#value_keys" do
    let(:result) { service.value_keys }

    context "when the rate basis is PER_UNIT_TON_CBM_RANGE" do
      let(:fee) { { "rate_basis" => "PER_UNIT_TON_CBM_RANGE" } }

      it "returns 'stowage' as the value key" do
        expect(result).to eq(["stowage_factor"])
      end
    end

    context "when the rate basis is PER_CBM_TON" do
      let(:fee) { { "rate_basis" => "PER_CBM_TON" } }

      it "returns 'cbm' and 'ton' as the value keys" do
        expect(result).to eq(%w[cbm ton])
      end
    end

    context "when the rate basis is PER_CBM" do
      let(:fee) { { "rate_basis" => "PER_CBM" } }

      it "returns 'cbm' as the value keys" do
        expect(result).to eq(["cbm"])
      end
    end

    context "when the rate basis is PER_KG_FLAT_RANGE" do
      let(:fee) { { "rate_basis" => "PER_KG_FLAT_RANGE" } }

      it "returns 'kg' as the value keys" do
        expect(result).to eq(["kg"])
      end
    end

    context "when a 'range_unit' value is present, it takes priority over the RATE_BASIS values" do
      let(:fee) { { "rate_basis" => "PER_SHIPMENT", "range_unit" => "kg" } }

      it "returns the range unit as the value key" do
        expect(result).to eq(["kg"])
      end
    end
  end

  describe "#fallback_value_keys" do
    let(:fee) { { "rate_basis" => "PER_SHIPMENT" } }
    let(:result) { service.fallback_value_keys }

    it "returns the value keys plus 'rate' and 'value'" do
      expect(result).to eq(%w[shipment rate value])
    end
  end
end
