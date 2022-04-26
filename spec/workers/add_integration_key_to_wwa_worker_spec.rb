# frozen_string_literal: true

require "rails_helper"
RSpec.describe AddIntegrationKeyToWwaWorker, type: :worker do
  describe "#perform" do
    subject(:perform) { described_class.new.perform }

    context "with valid params" do
      before { FactoryBot.create(:organizations_organization, slug: described_class::WWA_SLUG) }

      it "creates a integration key for the organization" do
        expect { perform }.to change { Organizations::IntegrationToken.count }.by(1)
      end
    end

    context "when organization with slug not found" do
      before { FactoryBot.create(:organizations_organization, slug: "different_org") }

      it "raises exception" do
        expect { perform }.to raise_error(StandardError)
      end
    end

    context "when integration token for the organization already exist" do
      before do
        FactoryBot.create(:organizations_organization, slug: described_class::WWA_SLUG)
        perform
      end

      it "does not create a new token" do
        expect { perform }.not_to(change { Organizations::IntegrationToken.count })
      end
    end
  end
end
