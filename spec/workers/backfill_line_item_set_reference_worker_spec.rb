# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillLineItemSetReferenceWorker, type: :worker do
  let!(:tender) { FactoryBot.create(:quotations_tender, id: backfilled_line_item_set.result_id) }
  let(:backfilled_line_item_set) do
    FactoryBot.build(:journey_line_item_set, reference: nil, result: FactoryBot.build(:journey_result, line_item_sets: [])).tap do |line_item_set|
      line_item_set.save(validate: false)
    end
  end
  let(:native_line_item_set) do
    FactoryBot.build(:journey_line_item_set,
      reference: nil,
      result: FactoryBot.build(:journey_result, line_item_sets: [], created_at: 3.seconds.ago))
      .tap do |line_item_set|
      line_item_set.save(validate: false)
    end
  end
  let!(:expected_native_reference) { Journey::ImcReference.new(date: native_line_item_set.result.created_at).reference }

  describe ".perform" do
    before { described_class.new.perform }

    it "updates the LineItemSets as expected", :aggregate_failures do
      expect(backfilled_line_item_set.reload.reference).to eq(tender.imc_reference)
      expect(native_line_item_set.reload.reference).to eq(expected_native_reference)
    end
  end
end
