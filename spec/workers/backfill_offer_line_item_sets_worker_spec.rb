# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillOfferLineItemSetsWorker, type: :worker do
  describe ".perform" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:query) { FactoryBot.create(:journey_query, organization: organization) }
    let(:result) { FactoryBot.create(:journey_result, query: query) }
    let(:edited_result) {
      FactoryBot.create(:journey_result,
        query: query,
        line_item_sets: [
          target_original_line_item_set,
          target_edited_line_item_set
        ])
    }
    let(:offer) { FactoryBot.create(:journey_offer, query: query, line_item_sets: []) }
    let(:target_line_item_set) { result.line_item_sets.first }
    let(:target_original_line_item_set) { FactoryBot.build(:journey_line_item_set, created_at: 10.minutes.ago) }
    let(:target_edited_line_item_set) { FactoryBot.build(:journey_line_item_set) }

    before do
      FactoryBot.create(:journey_offer_result, offer: offer, result: result)
      FactoryBot.create(:journey_offer_result, offer: offer, result: edited_result)
      FactoryBot.create(:journey_offer).tap do |other_offer|
        FactoryBot.create(:journey_offer_result, offer: other_offer)
      end
      described_class.new.perform
    end

    it "ports the offer to the line item sets", :aggregate_failures do
      expect(offer.reload.line_item_sets).to match_array([target_line_item_set,
        target_original_line_item_set])
      expect(Journey::Offer.count).to eq(2)
    end
  end
end
