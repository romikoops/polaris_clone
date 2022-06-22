# frozen_string_literal: true

require "rails_helper"

RSpec.describe RepublishMissedEventsWorker, type: :worker do
  let(:unsent_event) do
    Journey::OfferCreated.new(
      data: { offer: FactoryBot.create(:journey_offer, query: query).to_global_id, organization_id: organization.id },
      metadata: { timestamp: period.last - 2.days }
    )
  end
  let(:sent_event) do
    Journey::OfferCreated.new(
      data: { offer: FactoryBot.create(:journey_offer, query: other_query).to_global_id, organization_id: organization.id },
      metadata: { timestamp: period.last + 2.days }
    )
  end
  let(:period) { Range.new(Date.parse("27/05/2022"), Date.parse("14/06/2022")) }
  let(:stream_name) { "Organization$#{organization.id}" }
  let(:organization) { FactoryBot.create(:organizations_organization, slug: "lclsaco") }
  let(:query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:other_query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:notifier_double) { class_double(Notifications::OfferCreated::AdminNotifierJob) }

  describe "perform" do
    before do
      Organizations.current_id = organization.id
      [unsent_event, sent_event].each do |event|
        Rails.configuration.event_store.publish(event, stream_name: stream_name)
      end
      allow(Notifications::OfferCreated::AdminNotifierJob).to receive(:set).and_return(notifier_double)
      allow(notifier_double).to receive(:perform_later)
      described_class.new.perform
    end

    it "republishes for the past events", :aggregate_failures do
      expect(notifier_double).to have_received(:perform_later).with(serialized_event(event: unsent_event))
      expect(notifier_double).not_to have_received(:perform_later).with(serialized_event(event: sent_event))
    end
  end
end

def serialized_event(event:)
  RubyEventStore::Mappers::Default.new.event_to_serialized_record(event).as_json
end
