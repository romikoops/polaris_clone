# frozen_string_literal: true

require "rails_helper"
require_relative "../../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreators::LegacyChargeBreakdown do
  include_context "full_offer"
  let(:tender) { OfferCalculator::Service::OfferCreators::Tender.tender(offer: offer, shipment: shipment, quotation: quotation) }
  let(:charge_breakdown) { described_class.charge_breakdown(offer: offer, shipment: shipment, tender: tender) }

  before { OfferCalculator::Service::OfferCreators::LineItems.line_items(offer: offer, shipment: shipment, tender: tender) }

  context "when it returns a valid charge breakdown" do
    it "returns a valid charge breakdown" do
      aggregate_failures do
        expect(charge_breakdown).to be_a(Legacy::ChargeBreakdown)
        expect(charge_breakdown).to be_valid
        expect(charge_breakdown.charges.where(detail_level: 3).count).to eq(offer.charges.length)
      end
    end
  end
end
