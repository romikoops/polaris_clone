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

    context "when subscription with empty filter as empty hash is created" do
      let(:empty_subscriptions) do
        FactoryBot.create(:notifications_subscriptions, filter: {})
      end

      it "returns filter to be an empty hash" do
        expect(empty_subscriptions.filter).to eq({})
      end
    end

    context "when subscription with empty filter is created" do
      let(:empty_subscriptions) do
        FactoryBot.create(:notifications_subscriptions,
          filter: {
            origins: "",
            destinations: "",
            mode_of_transports: "",
            groups: ""
          })
      end

      it "returns filter to be an empty hash" do
        expect(empty_subscriptions.filter).to eq({})
      end
    end

    context "when subscription with a filter is created" do
      let(:subscription_with_filter) do
        FactoryBot.create(:notifications_subscriptions,
          filter: {
            origins: "DEHAM",
            destinations: "",
            mode_of_transports: "",
            groups: ""
          })
      end

      it "returns filter to have the origin" do
        expect(subscription_with_filter.filter).to eq({ "origins" => "DEHAM" })
      end
    end
  end
end
