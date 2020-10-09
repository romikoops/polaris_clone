# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::TenderLineItems do
  include_context "full_offer"
  let(:tender) { FactoryBot.create(:quotations_tender, quotation: quotation) }
  let(:updated_tender) { described_class.tender(offer: offer, tender: tender, shipment: shipment) }
  let(:line_items) { updated_tender.line_items }
  let(:expected_total) { line_items.inject(Money.new(0, "EUR")) { |sum, item| sum + item.amount }.round }

  context "when it returns a valid line_items" do
    it "returns a valid line_items" do
      aggregate_failures do
        expect(line_items.first).to be_a(Quotations::LineItem)
        expect(line_items.first).to be_valid
        expect(line_items.count).to eq(offer.charges.length)
        expect(expected_total).to eq(tender.amount)
      end
    end
  end
end
