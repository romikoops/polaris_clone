# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::ResultBuilder do
  include_context "full_offer"

  let(:offers) { [offer] }
  let(:result) { described_class.result(offer: offer, request: request) }

  describe ".result" do
    before do
      Organizations.current_id = organization.id
      allow(Carta::Client).to receive(:suggest).and_return(FactoryBot.build(:carta_result))
    end

    it "returns the correct number of results for the number of offers" do
      expect(result).to be_persisted
    end

    it "returns the correct query_id" do
      expect(result.query.id).to eq result.query_id
    end

    context "when an error occurs" do
      before { allow(OfferCalculator::Service::OfferCreators::LineItemBuilder).to receive(:line_items).and_raise(ActiveRecord::RecordInvalid) }

      it "raises an OfferCalculator::Errors::OfferBuilder error" do
        expect { result }.to raise_error(OfferCalculator::Errors::OfferBuilder)
      end
    end
  end
end
