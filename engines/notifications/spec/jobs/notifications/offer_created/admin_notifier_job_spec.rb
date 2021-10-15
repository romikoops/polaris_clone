# frozen_string_literal: true

require "rails_helper"
RSpec.describe Notifications::OfferCreated::AdminNotifierJob, type: :job do
  include ActiveJob::TestHelper
  let!(:subscription) do
    Notifications::Subscription.create(
      organization: offer.query.organization,
      event_type: "Journey::OfferCreated",
      email: "test@example.com"
    )
  end

  let(:sent_event) do
    RubyEventStore::Mappers::Default.new.event_to_serialized_record(
      Journey::OfferCreated.new(data: { offer: offer.to_global_id, organization_id: offer.query.organization.id })
    )
  end

  let(:offer) { FactoryBot.create(:journey_offer) }

  describe "perform" do
    let!(:admin_notifier_job) { described_class.new }
    let(:subscription_empty) { FactoryBot.create(:notifications_subscriptions, filter: {}, organization: offer.query.organization) }
    let(:subscription_filter) { { mode_of_transports: mot, origins: origins } }
    let(:origins) { "" }
    let(:mot) { "" }

    before { subscription_empty }

    shared_examples_for "subscription with empty filter is selected" do
      it "email for the subscription with empty filter is sent" do
        perform_enqueued_jobs do
          admin_notifier_job.perform(sent_event.as_json)
        end
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include subscription_empty.email
      end
    end

    shared_examples_for "subscription with matching filter is selected" do
      it "email for the subscription with matching filter is sent" do
        perform_enqueued_jobs do
          admin_notifier_job.perform(sent_event.as_json)
        end
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include subscription.email
      end
    end

    context "when mode of transport on offer is ocean" do
      let(:mot) { "ocean" }
      let(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter, organization: offer.query.organization) }

      before { subscription }

      it_behaves_like "subscription with empty filter is selected"
      it_behaves_like "subscription with matching filter is selected"
    end

    context "when one of the filter on the subscription matches the offer" do
      let(:mot) { "truck" }
      let(:origins) { "DEHAM" }
      let(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter, organization: offer.query.organization) }

      before { subscription }

      it_behaves_like "subscription with empty filter is selected"

      # Even though the subscription had mode_of_transports as truck and offer has it as ocean,
      # it is valid since the origin of the offer and subscription matches
      it_behaves_like "subscription with matching filter is selected"
    end

    context "when offer's organization is different from the subscription's organization but origins match" do
      let(:origins) { "DEHAM" }
      let(:subscription) { FactoryBot.create(:notifications_subscriptions, filter: subscription_filter) }

      before { subscription }

      it "verifies that email is not sent to the subscriber of different org" do
        perform_enqueued_jobs do
          admin_notifier_job.perform(sent_event.as_json)
        end
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).not_to include subscription.email
      end

      it_behaves_like "subscription with empty filter is selected"
    end
  end
end
