# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackfillUsersClientsWithNoSettingsOrProfilesWorker, type: :worker do
  describe "#perform" do
    it "assigns a new client profile, when a user client does not have one" do
      users_client = create_users_client(options: { profile: nil })
      described_class.new.perform
      expect(users_client.reload.profile).to be_an_instance_of(Users::ClientProfile)
    end

    it "assigns a new client setting, when a user client does not have one" do
      users_client = create_users_client(options: { settings: nil })
      described_class.new.perform
      expect(users_client.reload.settings).to be_an_instance_of(Users::ClientSettings)
    end

    it "verifies that the new client setting, contains the currency from the users client's organization's scope content" do
      organization = FactoryBot.build(:organizations_organization)
      organization.scope.content = { default_currency: "USD" }
      users_client = create_users_client(options: { settings: nil, organization: organization })

      described_class.new.perform
      expect(users_client.reload.settings.currency).to eq("USD")
    end

    def create_users_client(options: {})
      users_client = FactoryBot.build(:users_client, options)
      users_client.save(validate: false) # Skipping validation. Before executing migration, there were some Users::Client instances with no Users::ClientProfile or Users::ClientSettings attached.
      users_client
    end
  end
end
