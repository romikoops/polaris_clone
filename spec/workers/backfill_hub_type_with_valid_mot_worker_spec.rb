# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillHubTypeWithValidMotWorker, type: :worker do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:hub_with_empty_hub_type) { FactoryBot.create(:hub, hub_type: "", organization: organization) }
  let!(:hub_with_invalid_truck_type_road) { FactoryBot.create(:hub, name: "unique_name", hub_type: "road", organization: organization) }
  let!(:hub_with_invalid_truck_type_trucking) { FactoryBot.create(:hub, name: "another_unique_name", hub_type: "trucking", organization: organization) }
  let!(:hub_with_valid_hub_type) { FactoryBot.create(:hub, organization: organization) }
  let!(:hub_with_invalid_hub_type_and_duplicate) { FactoryBot.create(:hub, hub_type: "road", nexus_id: hub_with_valid_hub_type.nexus_id, organization: organization) }

  describe "#perform" do
    context "when backfill is successful" do
      before do
        described_class.new.perform
      end

      it "destroys hubs with empty hub_type" do
        expect { hub_with_empty_hub_type.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "destroys duplicate hubs with invalid hub_type" do
        expect { hub_with_invalid_hub_type_and_duplicate.reload }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "verifies valid hub is present" do
        expect(hub_with_valid_hub_type.reload).to be_present
      end

      it "changes hub_type from `road` to `truck`" do
        expect(hub_with_invalid_truck_type_road.reload.hub_type).to eq "truck"
      end

      it "changes hub_type from `trucking` to `truck`" do
        expect(hub_with_invalid_truck_type_trucking.reload.hub_type).to eq "truck"
      end
    end
  end

  context "when hub_type is invalid and not corrected" do
    before do
      FactoryBot.create(:hub, hub_type: "random", organization: organization)
    end

    it "raises failedhubtype exception" do
      expect { described_class.new.perform }.to raise_error(BackfillHubTypeWithValidMotWorker::FailedHubTypeBackFill)
    end
  end
end
