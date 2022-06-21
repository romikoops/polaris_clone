# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Support::ValueExtractor do
  let(:result) { described_class.new(value_key: value_key, range: range).perform }

  describe "#perform" do
    context "when the rate basis is 'PER_UNIT_TON_CBM_RANGE' and the ton fee is present" do
      let(:value_key) { "stowage_factor" }
      let(:range) { { "rate_basis" => "PER_UNIT_TON_CBM_RANGE", "ton" => 10, "min" => 0, "max" => 10 } }

      expected_data = { "range_min" => 0, "range_max" => 10, "range_unit" => "stowage_factor", "rate_basis" => "PER_TON", "rate" => 10 }
      it "returns the correct rate values for the PER_TON section" do
        expect(result).to eq(expected_data)
      end
    end

    context "when the rate basis is 'PER_UNIT_TON_CBM_RANGE' and the cbm fee is present" do
      let(:value_key) { "stowage_factor" }
      let(:range) { { "rate_basis" => "PER_UNIT_TON_CBM_RANGE", "cbm" => 6, "min" => 10, "max" => 20 } }

      expected_data = { "range_min" => 10, "range_max" => 20, "range_unit" => "stowage_factor", "rate_basis" => "PER_CBM", "rate" => 6 }
      it "returns the correct rate values for the PER_CBM section" do
        expect(result).to eq(expected_data)
      end
    end

    context "when the rate basis is not 'PER_UNIT_TON_CBM_RANGE' and rate is under 'rate' key" do
      let(:range) { { "rate_basis" => "PER_SHIPMENT", "rate" => 10 } }
      let(:value_key) { "shipment" }

      expected_data = { "range_min" => 0, "range_max" => Float::INFINITY, "range_unit" => "shipment", "rate_basis" => "PER_SHIPMENT", "rate" => 10 }
      it "returns the correct rate values for the PER_SHIPMENT even when value is not under 'value_key'" do
        expect(result).to eq(expected_data)
      end
    end
  end
end
