# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillQueryIdToResultWorker, type: :worker do
  describe "#perform", skip: true do
    let!(:journey_result) { FactoryBot.create(:journey_result) }

    it "backfills result_set query id to result query_id" do
      described_class.new.perform
      journey_result.reload
      expect(journey_result.query_id).to eq journey_result.result_set.query.id
    end

    context "when result query_id is nil but result_set query id is present after perform" do
      let!(:backfill_instance) { described_class.new }
      let(:random_query) { FactoryBot.create(:journey_query) }
      let(:new_result_set) { FactoryBot.create(:journey_result_set) }

      before do
        FactoryBot.create(:journey_result, result_set: new_result_set)
      end

      it "raises `FailedQueryIdBackFill`" do
        journey_result.query_id = random_query.id
        journey_result.save!
        allow(backfill_instance).to receive(:journey_result_backfill_sql).and_return(nil)
        expect { backfill_instance.perform }.to raise_error(BackfillQueryIdToResultWorker::FailedQueryIdBackFill)
      end
    end
  end
end
