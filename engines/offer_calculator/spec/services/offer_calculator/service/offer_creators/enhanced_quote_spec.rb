# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::EnhancedQuote do
  include_context "full_offer"
  let(:tender) { OfferCalculator::Service::OfferCreators::Tender.tender(offer: offer, shipment: shipment, quotation: quotation) }
  let(:scope) { {} }
  let(:charge_breakdown) { OfferCalculator::Service::OfferCreators::LegacyChargeBreakdown.charge_breakdown(offer: offer, shipment: shipment, tender: tender) }
  let(:quote) do
    described_class.quote(
      offer: offer,
      charge_breakdown: charge_breakdown,
      scope: scope
    )
  end

  before { OfferCalculator::Service::OfferCreators::LineItems.line_items(offer: offer, shipment: shipment, tender: tender) }

  context "when it returns a complete quote" do
    it "returns a complete quote with rate data" do
      aggregate_failures do
        expect(quote).to be_a(Hash)
        expect(quote.keys.map(&:to_s)).to match_array(%w[total edited_total name trucking_pre export cargo import trucking_on])
        expect(quote.dig("cargo", shipment.cargo_units.first.id, "bas", :rate)).to eq(value: 0.25e3, currency: "EUR")
        expect(quote.dig("cargo", shipment.cargo_units.first.id, "bas", :min_value)).to eq(value: 0, currency: "USD")
      end
    end
  end

  context "when it hides the grand total" do
    let(:scope) { {hide_grand_total: true} }

    it "returns a complete quote with hidden grand total" do
      aggregate_failures do
        expect(quote).to be_a(Hash)
        expect(quote.keys.map(&:to_s)).to match_array(%w[total edited_total name trucking_pre export cargo import trucking_on])
        expect(quote.dig("total")).to be_nil
      end
    end
  end

  context "when it hides the sub total" do
    let(:scope) { {hide_sub_totals: true} }

    it "returns a complete quote with hidden grand total" do
      aggregate_failures do
        expect(quote).to be_a(Hash)
        expect(quote.keys.map(&:to_s)).to match_array(%w[total edited_total name trucking_pre export cargo import trucking_on])
        expect(quote.dig("cargo", "total")).to be_nil
      end
    end
  end
end
