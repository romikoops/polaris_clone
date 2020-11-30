# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::Tender do
  include_context "full_offer"
  let(:tender) { described_class.tender(offer: offer, shipment: shipment, quotation: quotation) }

  context "when it returns a valid tender" do
    it "returns a valid tender" do
      aggregate_failures do
        expect(tender).to be_a(Quotations::Tender)
        expect(tender).to be_valid
      end
    end
  end
end
