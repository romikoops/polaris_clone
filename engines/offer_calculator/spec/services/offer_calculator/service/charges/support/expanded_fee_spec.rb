# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Support::ExpandedFee do
  let(:result) { described_class.new(fee: fee, base: base).perform }

  let(:base) { { "currency" => "EUR", "context_id" => "aaa-bbb-ccc" } }

  describe "#perform" do
    context "when the rate basis is PER_UNIT_TON_CBM_RANGE" do
      let(:fee) do
        { "code" => "QDF",
          "max" => nil,
          "min" => 57,
          "name" => "Wharfage / Quay Dues",
          "range" => [
            { "max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR" },
            { "cbm" => 8, "max" => 40, "min" => 6, "currency" => "EUR" }
          ],
          "currency" => "EUR",
          "rate_basis" => "PER_UNIT_TON_CBM_RANGE" }
      end
      let(:expected_data) do
        [
          { "range_min" => 0, "range_max" => 5, "rate" => 41, "range_unit" => "stowage_factor", "rate_basis" => "PER_TON", "min" => 57, "max" => nil },
          { "range_min" => 6, "range_max" => 40, "rate" => 8, "range_unit" => "stowage_factor", "rate_basis" => "PER_CBM", "min" => 57, "max" => nil }
        ].map do |expected_range_data|
          base.merge(fee.except("range")).merge(expected_range_data)
        end
      end

      it "returns one row for each range subsection with all the base data included" do
        expect(result).to eq(expected_data)
      end
    end

    context "when the rate basis is PER_SHIPMENT and rate is under 'rate' key" do
      let(:fee) do
        {
          "code" => "SOLAS",
          "max" => nil,
          "min" => 17.5,
          "name" => "SOLAS",
          "rate" => 17.5,
          "currency" => "EUR",
          "rate_basis" => "PER_SHIPMENT",
          "range" => []
        }
      end

      expected_data = [{ "currency" => "EUR",
                         "context_id" => "aaa-bbb-ccc",
                         "code" => "SOLAS",
                         "max" => nil,
                         "min" => 17.5,
                         "name" => "SOLAS",
                         "rate" => 17.5,
                         "rate_basis" => "PER_SHIPMENT",
                         "range_min" => 0,
                         "range_max" => Float::INFINITY,
                         "range_unit" => "shipment" }]

      it "returns the the single fee merged with the base object" do
        expect(result).to eq(expected_data)
      end
    end

    context "when the rate basis is PER_SHIPMENT and rate is under 'shipment' key" do
      let(:fee) do
        {
          "code" => "SOLAS",
          "max" => nil,
          "min" => 17.5,
          "name" => "SOLAS",
          "shipment" => 17.5,
          "currency" => "EUR",
          "rate_basis" => "PER_SHIPMENT",
          "range" => []
        }
      end

      expected_data = [{ "currency" => "EUR",
                         "context_id" => "aaa-bbb-ccc",
                         "code" => "SOLAS",
                         "max" => nil,
                         "min" => 17.5,
                         "name" => "SOLAS",
                         "rate" => 17.5,
                         "rate_basis" => "PER_SHIPMENT",
                         "range_min" => 0,
                         "range_max" => Float::INFINITY,
                         "range_unit" => "shipment" }]

      it "returns the the single fee merged with the base object" do
        expect(result).to eq(expected_data)
      end
    end
  end
end
