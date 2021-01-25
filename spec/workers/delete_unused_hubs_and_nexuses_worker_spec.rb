require "rails_helper"
RSpec.describe DeleteUnusedHubsAndNexusesWorker, type: :worker do
  context "when hub has no hub_code" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:hub) { FactoryBot.create(:legacy_hub, hub_code: nil) }
    let!(:legacy_itinerary) { FactoryBot.create(:legacy_itinerary, :default, origin_hub: hub) }
    let!(:local_charges) { FactoryBot.create(:legacy_local_charge, hub: hub, organization: organization) }

    it "deletes hubs" do
      described_class.new.perform

      expect(Legacy::Hub.all).to be_empty
    end

    it "deletes hub itineraries" do
      described_class.new.perform

      expect(Legacy::Itinerary.all).to be_empty
    end

    it "deletes assoiciated local charges" do
      described_class.new.perform

      expect(Legacy::LocalCharge.all).to be_empty
    end
  end

  context "when hub has hub_code" do
    let!(:hub) { FactoryBot.create(:legacy_hub, :hamburg) }

    it "doesn't delete hubs " do
      described_class.new.perform

      expect(Legacy::Hub.find(hub.id)).to be_present
    end
  end

  context "when nexus has no locode" do
    let!(:nexus) { FactoryBot.create(:legacy_nexus, locode: nil) }

    it "deletes nexuses" do
      described_class.new.perform

      expect(Legacy::Nexus.all).to be_empty
    end
  end

  context "when nexus has locode" do
    let!(:nexus) { FactoryBot.create(:legacy_nexus, :gothenburg) }

    it "doesn't delete nexuses" do
      described_class.new.perform

      expect(Legacy::Nexus.find(nexus.id)).to be_present
    end
  end
end
