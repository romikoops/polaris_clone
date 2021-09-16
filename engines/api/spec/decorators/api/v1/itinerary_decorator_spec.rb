# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::ItineraryDecorator do
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let(:scope) { Organizations::DEFAULT_SCOPE }
  let(:decorated_itinerary) { described_class.new(itinerary, context: { scope: scope }) }
  let(:pricing) do
    FactoryBot.create(:pricings_pricing,
      expiration_date: Time.zone.tomorrow.beginning_of_day,
      itinerary: itinerary)
  end

  describe "#legacy_json" do
    let(:legacy_json) { decorated_itinerary.legacy_json }
    let(:expected) do
      {
        origin: decorated_itinerary.origin_hub.name,
        destination: decorated_itinerary.destination_hub.name,
        transshipment: itinerary.transshipment,
        mode_of_transport: itinerary.mode_of_transport,
        name: itinerary.name,
        id: itinerary.id
      }
    end

    shared_examples_for "returning the correct data" do
      it "returns the data with the correct last_expiry value" do
        expect(legacy_json).to eq(expected.merge(last_expiry: expected_date))
      end
    end

    context "without rates" do
      let(:expected_date) { nil }

      it_behaves_like "returning the correct data"
    end

    context "with rates" do
      before { pricing }

      let(:expected_date) { pricing.expiration_date }

      it_behaves_like "returning the correct data"
    end
  end
end
