# frozen_string_literal: true

require "rails_helper"
RSpec.describe BackfillNewDefaultToFilterInSubscriptionWorker, type: :worker do
  let!(:notifiation_subscription) { FactoryBot.create(:notifications_subscriptions, filter: "{}") }

  describe "#perform" do
    it "changes filter from '{}' to {}" do
      expect { described_class.new.perform }.to change { notifiation_subscription.reload.filter }.from("{}").to({})
    end

    context "with existing record types" do
      let!(:notifiation_subscription_empty_hash) { FactoryBot.create(:notifications_subscriptions, filter: {}) }

      it "does not effect empty hash" do
        expect { described_class.new.perform }.not_to(change { notifiation_subscription_empty_hash.reload.filter })
      end
    end
  end
end
