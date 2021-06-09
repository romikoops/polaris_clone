# frozen_string_literal: true

require "rails_helper"
RSpec.describe SetEmptyTendersAsFailedWorker, type: :worker do
  let(:result_set) { FactoryBot.build(:journey_result_set, results: [result]) }
  let(:result) { FactoryBot.build(:journey_result, id: tender.id, created_at: tender.created_at) }
  let(:native_result_set) { FactoryBot.build(:journey_result_set, results: [native_result]) }
  let(:native_result) { FactoryBot.build(:journey_result) }
  let!(:tender) { FactoryBot.create(:quotations_tender, line_items: []) }

  before do
    FactoryBot.create(:journey_query, result_sets: [result_set])
    FactoryBot.create(:journey_query, result_sets: [native_result_set])
    described_class.new.perform
  end

  describe ".perform" do
    it "marks only the backfilled ResultSet as failed, leaving the other untouched", :aggregate_failures do
      expect(native_result_set.reload.status).to eq("completed")
      expect(result_set.reload.status).to eq("failed")
    end
  end
end
