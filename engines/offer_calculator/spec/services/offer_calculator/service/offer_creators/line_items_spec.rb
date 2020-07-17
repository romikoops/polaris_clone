# frozen_string_literal: true

require "rails_helper"
require_relative "../../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreators::LineItems do
  include_context "full_offer"
  let(:tender) { FactoryBot.create(:quotations_tender, quotation: quotation) }
  let(:line_items) { described_class.line_items(offer: offer, tender: tender, shipment: shipment) }

  context "when it returns a valid line_items" do
    it "returns a valid line_items" do
      aggregate_failures do
        expect(line_items.first).to be_a(Quotations::LineItem)
        expect(line_items.first).to be_valid
        expect(line_items.count).to eq(offer.charges.length)
      end
    end
  end
end
