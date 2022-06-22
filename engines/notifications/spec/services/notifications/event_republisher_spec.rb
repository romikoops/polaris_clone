# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::EventRepublisher do
  let(:offer_created_event) do
    Journey::OfferCreated.new(
      data: { offer: FactoryBot.create(:journey_offer, query: query).to_global_id, organization_id: organization.id },
      metadata: { timestamp: period.last - 2.days }
    )
  end
  let(:shipment_request_event) do
    Journey::ShipmentRequestCreated.new(
      data: { organization_id: organization.id },
      metadata: { timestamp: period.last - 2.days }
    )
  end
  let(:period) { Range.new(Date.parse("27/05/2022"), Date.parse("14/06/2022")) }
  let(:stream_name) { "Organization$#{organization.id}" }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:other_query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:notifier_double) { class_double(Notifications::OfferCreated::AdminNotifierJob) }
  let(:shipment_request_double) { class_double(Notifications::ShipmentRequestCreatedJob) }

  describe ".perform" do
    before do
      Organizations.current_id = organization.id
      allow(Notifications::OfferCreated::AdminNotifierJob).to receive(:set).and_return(notifier_double)
      allow(Notifications::ShipmentRequestCreatedJob).to receive(:set).and_return(shipment_request_double)
      allow(notifier_double).to receive(:perform_later)
      allow(shipment_request_double).to receive(:perform_later)
      described_class.new(events: [offer_created_event, shipment_request_event]).perform
    end

    it "triggers the correct job for the correct event", :aggregate_failures do
      expect(notifier_double).to have_received(:perform_later).with(serialized_event(event: offer_created_event))
      expect(notifier_double).not_to have_received(:perform_later).with(serialized_event(event: shipment_request_event))
      expect(shipment_request_double).to have_received(:perform_later).with(serialized_event(event: shipment_request_event))
    end
  end
end

def serialized_event(event:)
  RubyEventStore::Mappers::Default.new.event_to_serialized_record(event).as_json
end
