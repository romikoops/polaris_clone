# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Support::RateBasisData do
  let(:result) { described_class.new(fee: fee).rate_basis }

  describe "#rate_basis" do
    context "when the rate basis is PER_UNIT_TON_CBM_RANGE and the ton fee is present" do
      let(:fee) { { "rate_basis" => "PER_UNIT_TON_CBM_RANGE", "ton" => 10 } }

      it "returns 'PER_TON' as the rate_basis" do
        expect(result).to eq("PER_TON")
      end
    end

    context "when the rate basis is PER_UNIT_TON_CBM_RANGE and the cbm fee is present" do
      let(:fee) { { "rate_basis" => "PER_UNIT_TON_CBM_RANGE", "cbm" => 10 } }

      it "returns 'PER_CBM' as the rate_basis" do
        expect(result).to eq("PER_CBM")
      end
    end

    context "when the rate basis is PER_CBM_TON" do
      let(:fee) { { "rate_basis" => "PER_CBM_TON" } }

      it "returns the rate_basis as is" do
        expect(result).to eq("PER_CBM_TON")
      end
    end

    context "when the rate basis is PER_KG_FLAT" do
      let(:fee) { { "rate_basis" => "PER_KG_FLAT" } }

      it "returns 'PER_SHIPMENT' as the rate_basis" do
        expect(result).to eq("PER_SHIPMENT")
      end
    end

    context "when the rate basis includes FLAT but does not match the pattern" do
      let(:fee) { { "rate_basis" => "PER_KG_FLAT_TOTAL" } }

      it "returns 'PER_KG_FLAT_TOTAL' as the rate_basis" do
        expect(result).to eq("PER_KG_FLAT_TOTAL")
      end
    end
  end
end
