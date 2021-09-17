# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillQueryIdToErrorsWorker, type: :worker do
  describe "#perform", skip: true do
    let!(:journey_error) { FactoryBot.create(:journey_error) }

    it "backfills result_set query id to errors query_id" do
      described_class.new.perform
      journey_error.reload
      expect(journey_error.query_id).to eq journey_error.result_set.query.id
    end

    context "when query_id is nil but result_set query id is present after perform" do
      let!(:backfill_instance) { described_class.new }
      let(:journey_error_instance) { FactoryBot.build(:journey_error, query: nil) }

      it "raises `FailedQueryIdBackFill`" do
        allow(backfill_instance).to receive(:journey_error_backfill_sql).and_return(nil)
        journey_error_instance.save!(validate: false)
        expect { backfill_instance.perform }.to raise_error(BackfillQueryIdToErrorsWorker::FailedQueryIdBackFill)
      end
    end
  end
end
