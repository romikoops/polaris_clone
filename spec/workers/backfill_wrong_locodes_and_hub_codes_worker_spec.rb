require 'rails_helper'
RSpec.describe BackfillWrongLocodesAndHubCodesWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  context "when hub has a wrong hub_code" do
    let!(:hub) { FactoryBot.create(:legacy_hub, hub_code: 'ANKRA', organization: organization) }

    it "corrects the hub_code" do
      described_class.new.perform

      expect(Legacy::Hub.find(hub.id).hub_code).to eq 'BQKRA'
    end
  end

  context "when nexus has a wrong locode" do
    let!(:nexus) { FactoryBot.create(:legacy_nexus, locode: 'ANPHI', organization: organization) }

    it "corrects the locode" do
      described_class.new.perform

      expect(Legacy::Nexus.find(nexus.id).locode).to eq 'SXPHI'
    end
  end
end
