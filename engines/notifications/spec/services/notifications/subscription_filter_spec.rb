# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::SubscriptionFilter do
  let!(:subscription) do
    Notifications::Subscription.create(
      organization: organization,
      event_type: event_type,
      email: "test@example.com"
    )
  end
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:event_type) { "Journey::ShipmentRequestCreated" }
  let(:result) { FactoryBot.create(:journey_result, query: FactoryBot.build(:journey_query, organization: organization)) }
  let(:sent_event) do
    instance_double("Event", event_type: event_type, data: { organization_id: organization.id })
  end

  describe "perform" do
    let(:filtered_subscriptions) { described_class.new(event: sent_event, results: [result]).subscriptions }
    let!(:subscription_empty) { FactoryBot.create(:notifications_subscriptions, event_type: event_type, filter: {}, organization: organization) }
    let(:subscription_filter) { { mode_of_transports: mot, origins: origins } }
    let(:origins) { "" }
    let(:mot) { "" }
    let!(:subscription) { FactoryBot.create(:notifications_subscriptions, event_type: event_type, filter: subscription_filter, organization: organization) }

    shared_examples_for "subscription with empty filter is selected" do
      it "email for the subscription with empty filter is sent" do
        expect(filtered_subscriptions).to include subscription_empty
      end
    end

    shared_examples_for "subscription with matching filter is selected" do
      it "email for the subscription with matching filter is sent" do
        expect(filtered_subscriptions).to include subscription
      end
    end

    context "when mode of transport is ocean" do
      let(:mot) { "ocean" }

      it_behaves_like "subscription with empty filter is selected"
      it_behaves_like "subscription with matching filter is selected"
    end

    context "when one of the filter on the subscription matches the shipment request" do
      let(:mot) { "truck" }
      let(:origins) { "DEHAM" }

      it_behaves_like "subscription with empty filter is selected"
      it_behaves_like "subscription with matching filter is selected"
    end

    context "when shipment request's organization is different from the subscription's organization but origins match" do
      let(:origins) { "DEHAM" }
      let!(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter, event_type: event_type) }

      it "verifies that email is not sent to the subscriber of different org" do
        expect(filtered_subscriptions).not_to include subscription
      end

      it_behaves_like "subscription with empty filter is selected"
    end
  end
end
