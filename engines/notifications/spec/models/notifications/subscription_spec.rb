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
  end
end
