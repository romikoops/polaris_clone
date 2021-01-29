# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::OfferBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:client) { FactoryBot.create(:users_client) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:scope) { {} }
  let(:offer_service) do
    described_class.new(
      results: [result]
    )
  end
  let(:offer) { offer_service.perform }

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
        FactoryBot.create(:journey_offer_result, offer: ex_offer, result: result)
      end
    end

    it "returns the existing offer" do
      expect(offer).to eq(existing_offer)
    end
  end
end
