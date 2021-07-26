# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillRoutingCarriersWorker, type: :worker do
  let(:legacy_carrier) { FactoryBot.create(:legacy_carrier) }
  let!(:routing_carrier) { FactoryBot.create(:routing_carrier, code: legacy_carrier.code) }
  let!(:new_carrier) { FactoryBot.create(:legacy_carrier) }

  before { described_class.new.perform }

  describe "#perform" do
    it "copies only the Carrier that doesn't exist in the Routing::Carrier table", :aggregate_failures do
      expect(Routing::Carrier.find_by(name: new_carrier.name, code: new_carrier.code)).to be_present
      expect(Routing::Carrier.where(code: legacy_carrier.code)).to eq([routing_carrier])
    end
  end
end
