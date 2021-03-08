# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::OfferCreators::ResultSetBuilder do
  include_context "full_offer"

  let(:offers) { [offer] }
  let(:result_set) { described_class.results_set(offers: offers, request: request) }

  describe ".result_set" do
    before { allow(OfferCalculator::Service::OfferCreators::ResultBuilder).to receive(:result).and_return(FactoryBot.create(:journey_result, result_set: request.result_set)) }

    it "returns the correct number of results for the number of offers" do
      expect(result_set.results.count).to eq(offers.count)
    end
  end
end
