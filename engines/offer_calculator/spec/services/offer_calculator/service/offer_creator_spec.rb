# frozen_string_literal: true

require "rails_helper"
require_relative "../../../shared_contexts/full_offer.rb"

RSpec.describe OfferCalculator::Service::OfferCreator do
  include_context "full_offer"
  let(:load_type) { "container" }
  let(:wheelhouse) { false }
  let(:offers) { [offer] }
  let(:results) do
    described_class.offers(
      shipment: shipment,
      quotation: quotation,
      offers: offers,
      wheelhouse: wheelhouse
    )
  end

  context "when creating the legacy response" do
    it "returns the legacy response format" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.keys).to match_array(%i[quote meta schedules notes])
      end
    end
  end

  context "when creating the wheelhouse response" do
    let(:wheelhouse) { true }

    it "returns the legacy response format" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first).to be_a(Quotations::Tender)
      end
    end
  end

  context "when a failure occurs" do
    let(:offers) { {error: "error"} }

    it "returns the legacy response format" do
      expect { results }.to raise_error(OfferCalculator::Errors::OfferBuilder)
    end
  end
end
