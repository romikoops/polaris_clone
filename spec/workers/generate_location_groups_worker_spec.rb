# frozen_string_literal: true

require "rails_helper"

RSpec.describe GenerateLocationGroupsWorker, type: :worker do
  let!(:organization) { FactoryBot.create(:organizations_organization) }

  context "when the org has the Nexuses already" do
    let!(:nexuses) do
      described_class::GROUPS.values.flatten.map do |locode|
        FactoryBot.create(:legacy_nexus, organization: organization, locode: locode)
      end
    end

    before { described_class.new.perform }

    it "creates LocationGroups for the Nexuses", :aggregate_failures do
      expect(Pricings::LocationGroup.select(:name).distinct.pluck(:name)).to match_array(described_class::GROUPS.keys)
      expect(Pricings::LocationGroup.where(organization: organization).pluck(:nexus_id)).to match_array(nexuses.map(&:id))
    end
  end

  context "when the org has none of the Nexuses already, but they exist for others" do
    let!(:nexuses) do
      described_class::GROUPS.values.flatten.uniq.map do |locode|
        FactoryBot.create(:legacy_nexus, organization: other_organization, locode: locode)
      end
    end
    let(:other_organization) { FactoryBot.create(:organizations_organization) }

    before { described_class.new.perform }

    it "creates Nexuses for the locodes and LocationGroups", :aggregate_failures do
      expect(Pricings::LocationGroup.select(:name).distinct.pluck(:name)).to match_array(described_class::GROUPS.keys)
      expect(Legacy::Nexus.where(organization: organization).pluck(:locode)).to match_array(nexuses.pluck(:locode))
    end

    it "updates all Organization Scopes to be `include_location_groups` as true" do
      expect(organization.scope.reload.include_location_groups).to be_truthy
    end
  end
end
