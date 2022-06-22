# frozen_string_literal: true

require "rails_helper"

RSpec.describe Notifications::EventFilter do
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
  let(:other_type_event) do
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

  describe ".perform" do
    let(:filtered_events) { described_class.new(type: Journey::OfferCreated, period: period, organization: organization).perform }

    before do
      [unsent_event, sent_event, other_type_event].each do |event|
        Rails.configuration.event_store.publish(event, stream_name: stream_name)
      end
    end

    it "returns events of the correct type, only from the given period" do
      expect(filtered_events).to eq([unsent_event])
    end
  end
end
