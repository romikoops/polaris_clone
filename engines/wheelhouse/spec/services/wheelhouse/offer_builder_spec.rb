# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::OfferBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:client) { FactoryBot.create(:users_client) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:scope) { {} }
  let(:offer_service) { described_class.new(results: [result]) }
  let(:offer) { offer_service.offer }

  before do
    allow(Pdf::Quotation::Client).to receive(:new).and_return(double(file: true))
  end

  context "when it returns a complete offer" do
    it "returns a complete offer with rate data" do
      expect(offer).to be_a(Journey::Offer)
    end
  end

  context "when an offer exists with those results" do
    let!(:existing_offer) do
      FactoryBot.create(:journey_offer, query: result.query).tap do |ex_offer|
        FactoryBot.create(:journey_offer_line_item_set,
          offer: ex_offer,
          line_item_set: result.line_item_sets.first)
      end
    end

    it "returns the existing offer" do
      expect(offer).to eq(existing_offer)
    end
  end
end
