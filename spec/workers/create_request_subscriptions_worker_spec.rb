# frozen_string_literal: true
require "rails_helper"

RSpec.describe CreateRequestSubscriptionsWorker, type: :worker do
  let!(:organization) { FactoryBot.create(:organizations_organization, theme: theme) }
  let(:theme) { FactoryBot.build(:organizations_theme, emails: {sales: {general: email}}) }
  let(:email) { "test@itsmcyargo.com" }
  let(:expected_subscription) {
    Notifications::Subscription.find_by(
      organization: organization,
      email: email,
      event_type: "Journey::RequestCreated"
    )
  }
  before { described_class.new.perform }

  it "creates a subscriptions for the organizations" do
    expect(expected_subscription).to be_present
  end
end
