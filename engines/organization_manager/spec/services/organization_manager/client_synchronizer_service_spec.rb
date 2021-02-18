# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationManager::ClientSynchronizerService do
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "fivestar") }
  let!(:be_organization) { FactoryBot.create(:organizations_organization, slug: "fivestar-be") }
  let!(:nl_organization) { FactoryBot.create(:organizations_organization, slug: "fivestar-nl") }
  let!(:clients) { FactoryBot.create_list(:users_client, 5, organization: organization) }
  let(:be_clients) { Users::Client.global.where(organization: be_organization) }
  let(:nl_clients) { Users::Client.global.where(organization: nl_organization) }

  describe ".perform" do
    before do
      described_class.new(
        organization: organization,
        target_organizations: [be_organization, nl_organization],
        emails: clients.pluck(:email)
      ).perform
    end

    it "duplicates the client into the sister shops", :aggregate_failures do
      expect(Users::Client.unscoped.count).to eq(15)
      expect(be_clients.count).to eq(5)
      expect(nl_clients.count).to eq(5)
    end

    it "duplicates the profiles into the sister shops", :aggregate_failures do
      expect(Users::ClientProfile.count).to eq(15)
      expect(Users::ClientProfile.where(user: be_clients).count).to eq(5)
      expect(Users::ClientProfile.where(user: nl_clients).count).to eq(5)
    end

    it "duplicates the user into the sister shops", :aggregate_failures do
      expect(Users::ClientSettings.count).to eq(15)
      expect(Users::ClientSettings.where(user: be_clients).count).to eq(5)
      expect(Users::ClientSettings.where(user: nl_clients).count).to eq(5)
    end
  end
end
