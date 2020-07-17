# frozen_string_literal: true

require "rails_helper"
require_relative "../../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreators::LegacyResponse do
  include_context "full_offer"
  let(:tender) { OfferCalculator::Service::OfferCreators::Tender.tender(offer: offer, shipment: shipment, quotation: quotation) }
  let(:scope) { {} }
  let(:charge_breakdown) { OfferCalculator::Service::OfferCreators::LegacyChargeBreakdown.charge_breakdown(offer: offer, shipment: shipment, tender: tender) }
  let(:meta) { FactoryBot.build(:legacy_meta) }
  let(:response) do
    described_class.response(
      offer: offer,
      charge_breakdown: charge_breakdown,
      meta: meta,
      scope: scope
    )
  end

  before { OfferCalculator::Service::OfferCreators::LineItems.line_items(offer: offer, shipment: shipment, tender: tender) }

  context "when it returns a complete legacy response" do
    it "returns a valid response" do
      aggregate_failures do
        expect(response).to be_a(Hash)
        expect(response.keys).to match_array(%i[quote meta schedules notes])
      end
    end
  end
end
