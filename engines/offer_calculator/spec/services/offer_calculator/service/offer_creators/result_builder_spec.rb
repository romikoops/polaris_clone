# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::ResultBuilder do
  include_context "full_offer"

  let(:offers) { [offer] }
  let(:result) { described_class.result(offer: offer, request: request) }

  describe ".result_set" do
    before do
      Organizations.current_id = organization.id
      allow(Carta::Client).to receive(:suggest).and_return(FactoryBot.build(:carta_result))
    end

    it "returns the correct number of results for the number of offers" do
      expect(result).to be_persisted
    end
  end
end
