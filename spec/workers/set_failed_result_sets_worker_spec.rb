# frozen_string_literal: true

require "rails_helper"
RSpec.describe SetFailedResultSetsWorker, type: :worker do
  let!(:bad_query) { FactoryBot.create(:journey_query) }

  describe ".perform" do
    before { described_class.new.perform }

    it "creates a ResultSet with the failed status for all Queries without ResultSets" do
      expect(bad_query.result_sets.first.status).to eq("failed")
    end
  end
end
