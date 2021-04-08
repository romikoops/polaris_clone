# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillLoadTypeOnJourneyQueriesWorker, type: :worker do
  let!(:cargo_unit_query) do
    FactoryBot.create(:journey_query).tap do |query|
      FactoryBot.create(:journey_cargo_unit, cargo_class: "lcl", query: query)
      query.update_column(:load_type, nil)
    end
  end
  let!(:tender_query) do
    FactoryBot.create(:journey_query, cargo_count: 0).tap do |query|
      FactoryBot.create(:journey_result_set, query: query, results: [FactoryBot.build(:journey_result, id: tender.id)])

      query.update_column(:load_type, nil)
    end
  end
  let(:tender) { FactoryBot.create(:quotations_tender, load_type: "container") }
  let!(:scope_default_query) do
    FactoryBot.create(:journey_query, organization: organization, cargo_count: 0).tap do |query|
      query.update_column(:load_type, nil)
    end
  end
  let(:result_set) { FactoryBot.build(:journey_result_set, query: query) }
  let(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
  let(:scope) { FactoryBot.create(:organizations_scope, content: { "modes_of_transport" => modes_of_transport }) }
  let(:modes_of_transport) { { "air" => { "container" => true } } }

  describe "perform" do
    before { described_class.new.perform }

    it "sets the load type based on one of three sources", :aggregate_failures do
      expect(cargo_unit_query.reload.load_type).to eq("lcl")
      expect(tender_query.reload.load_type).to eq("fcl")
      expect(scope_default_query.reload.load_type).to eq("fcl")
    end
  end
end
