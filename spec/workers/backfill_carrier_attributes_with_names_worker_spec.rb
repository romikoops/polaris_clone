# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillCarrierAttributesWithNamesWorker, type: :worker do
  let(:routing_carrier) { FactoryBot.create(:routing_carrier) }
  let!(:route_section) { FactoryBot.create(:journey_route_section, carrier: routing_carrier.code) }
  let!(:false_target_route_section) { FactoryBot.create(:journey_route_section, carrier: routing_carrier.name) }

  describe "#perform" do
    before { described_class.new.perform }

    it "renames carrier only on the RouteSections that have carrier code persisted", :aggregate_failures do
      expect(route_section.reload.carrier).to eq(routing_carrier.name)
      expect(false_target_route_section.carrier).to eq(false_target_route_section.reload.carrier)
    end
  end
end
