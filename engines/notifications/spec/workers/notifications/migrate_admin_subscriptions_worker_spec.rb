require "rails_helper"

module Notifications
  RSpec.describe MigrateAdminSubscriptionsWorker, type: :worker do
    before do
      # Create organization to be migrated
      ::FactoryBot.create(:organizations_scope, content: {email_on_registration: true})

      # Create organization not to be migrated
      ::FactoryBot.create(:organizations_scope, content: {email_on_registration: false})
    end

    it "migrates user created subscription" do
      expect { described_class.new.perform }.to change { ::Notifications::Subscription.count }.by(1)
    end
  end
end
