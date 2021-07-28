# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillTerminalsOnHubsWorker, type: :worker do
  let!(:hub_to_ignore) { FactoryBot.create(:legacy_hub, name: "BGN/PCGN1956 - HAMAD") }
  let!(:hub_to_fix) { FactoryBot.create(:legacy_hub, name: "Ho Chi Minh - Cat lai") }
  let!(:other_hub) { FactoryBot.create(:legacy_hub, name: "Ho Chi Minh") }

  before do
    described_class.new.perform
    hub_to_ignore.reload
    hub_to_fix.reload
    other_hub.reload
  end

  describe "#perform" do
    it "only adjusts the hubs with dashes, ignoring the special case", :aggregate_failures do
      expect(hub_to_ignore.name).to eq("BGN/PCGN1956 - HAMAD")
      expect(other_hub.name).to eq("Ho Chi Minh")
      expect(hub_to_fix.name).to eq("Ho Chi Minh")
      expect(hub_to_fix.terminal).to eq("Cat lai")
    end
  end
end
