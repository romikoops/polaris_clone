# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::LegacyChargeBreakdown do
  include_context "full_offer"
  let(:tender) {
    OfferCalculator::Service::OfferCreators::Tender.tender(offer: offer, shipment: shipment, quotation: quotation)
  }
  let(:charge_breakdown) { described_class.charge_breakdown(offer: offer, shipment: shipment, tender: tender) }

  before do
    OfferCalculator::Service::OfferCreators::TenderLineItems.tender(offer: offer, shipment: shipment, tender: tender)
  end

  context "when it returns a valid charge breakdown" do
    it "returns a valid charge breakdown" do
      aggregate_failures do
        expect(charge_breakdown).to be_a(Legacy::ChargeBreakdown)
        expect(charge_breakdown).to be_valid
        expect(charge_breakdown.charges.where(detail_level: 3).count).to eq(offer.charges.length)
        expect(charge_breakdown.grand_total.price.money).to eq(tender.amount)
      end
    end
  end
end
