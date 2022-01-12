# frozen_string_literal: true

require "rails_helper"

module Notifications
  RSpec.describe RequestForQuotationJob, type: :job do
    include ActiveJob::TestHelper

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:query) { FactoryBot.create(:journey_query, organization: organization) }
    let(:request_for_quotation_notifier_job) { described_class.new }
    let!(:subscription) do
      Notifications::Subscription.create(
        organization: organization,
        event_type: "Journey::RequestCreated",
        email: "test@example.com"
      )
    end

    let(:sent_event) do
      RubyEventStore::Mappers::Default.new.event_to_serialized_record(
        Journey::RequestForQuotationEvent.new(data: data)
      )
    end

    let(:request_for_quotation) { FactoryBot.create(:request_for_quotation, organization: organization, query: query) }

    let(:data) { { query_id: query.to_global_id, request_for_quotation_id: request_for_quotation.to_global_id } }

    describe "#perform" do
      it "sends email for the subscriber" do
        perform_enqueued_jobs do
          request_for_quotation_notifier_job.perform(sent_event.as_json)
        end
        expect(ActionMailer::Base.deliveries.map(&:to).flatten).to include(subscription.email)
      end
    end
  end
end
