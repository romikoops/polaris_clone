# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::OfferBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:client) { FactoryBot.create(:users_client) }
  let(:result) { FactoryBot.create(:journey_result) }
  let(:scope) { {} }
  let(:offer_service) { described_class.new(results: [result]) }
  let(:offer) { offer_service.offer }
  let(:mailer_job) { double(deliver_later: true) }
  let(:pdf_spy) { spy("Pdf::Quotation::Client", file: true) }
  let(:event_spy) { spy("EventStore", publish: true) }

  before do
    allow(Pdf::Quotation::Client).to receive(:new).and_return(pdf_spy)
    allow(offer_service).to receive(:publish_event).and_return(event_spy)
  end

  context "when it returns a complete offer" do
    it "returns a complete offer with rate data", :aggregate_failures do
      expect(offer).to be_a(Journey::Offer)
      expect(pdf_spy).to have_received(:file)
      expect(offer_service).to have_received(:publish_event)
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

    it "returns the existing offer", :aggregate_failures do
      expect(offer).to eq(existing_offer)
      expect(offer_service).not_to have_received(:publish_event)
    end
  end
end
