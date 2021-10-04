# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe Subscription, type: :model do
    let(:notifications_subscriptions) { FactoryBot.build(:notifications_subscriptions) }

    it "builds a valid subscription" do
      expect(notifications_subscriptions).to be_valid
    end

    describe "#define_getters" do
      Notifications::Subscription::FILTERS.each do |method_name|
        it "#{method_name} getter should be defined" do
          expect(notifications_subscriptions).to respond_to(method_name.to_sym)
        end
      end
    end

    describe "#define_setters" do
      Notifications::Subscription::FILTERS.each do |method_name|
        it "#{method_name} setter should be defined" do
          notifications_subscriptions.send("#{method_name}=", "test")
          expect(notifications_subscriptions).to respond_to("#{method_name}=".to_sym)
        end
      end
    end

    describe "#filter" do
      shared_examples_for "empty filter subscription exist" do
        it "returns subscription with empty filter by default" do
          expect(described_class.filtered(offer_filter)).to include(subscription_empty)
        end
      end
      let(:offer_filter) { { mode_of_transports: [mot], origins: [origins], destinations: [destinations], groups: [groups] } }
      let(:subscription_filter) { { mode_of_transports: mot, origins: origins, destinations: destinations, groups: groups } }
      let!(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter) }
      let(:origins) { "" }
      let(:destinations) { "" }
      let(:groups) { "" }
      let(:mot) { "" }

      let!(:subscription_empty) { FactoryBot.create(:notifications_subscriptions, filter: "{}") }

      context "when filtering schdules by mode of transports" do
        let(:mot) { "ocean" }

        it "returns subscriptions by specified mode of transports" do
          expect(described_class.filtered(offer_filter)).to include(subscription)
        end

        it_behaves_like "empty filter subscription exist"
      end

      context "with origin only" do
        let(:origin) { "DEHAM" }

        it "returns subscriptions by origin" do
          expect(described_class.filtered(offer_filter)).to include(subscription)
        end

        it_behaves_like "empty filter subscription exist"
      end

      context "with origin and mot but mot is different" do
        let(:mot) { "air" }
        let(:origins) { "DEHAM" }
        let(:schedule_filter) { { mode_of_transports: "ocean", origins: origins, destinations: "", groups: "" } }
        let!(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: schedule_filter) }

        it "returns subscriptions by origin since it matches by origin" do
          expect(described_class.filtered(offer_filter).pluck(:id)).to include(subscription.id)
        end

        it_behaves_like "empty filter subscription exist"
      end

      context "with same origin but different organizations" do
        let(:origins) { "DEHAM" }
        let(:organization) { FactoryBot.create(:organizations_organization) }
        let!(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter) }
        let!(:subscription_new_org) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter, organization: organization) }
        let(:filtered_subscriptions) { described_class.where(organization: organization).filtered(offer_filter) }

        it "returns subscriptions filter for specified organization" do
          expect(filtered_subscriptions.pluck(:id)).to include(subscription_new_org.id)
        end

        it "does not include subscription from other organization" do
          expect(filtered_subscriptions.pluck(:id)).not_to include(subscription.id)
        end

        it_behaves_like "empty filter subscription exist"
      end
    end
  end
end
