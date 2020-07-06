# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::NoteDecorator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:organization_2) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
  let(:pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary) }

  describe "#legacy_json" do
    context "when note has an itinerary target set" do
      let(:note) { FactoryBot.create(:legacy_note, target: itinerary, organization: organization) }
      let(:decorated_note_json) { described_class.new(note).legacy_json }
      let(:decorated_note_2_json) { described_class.new(note_2).legacy_json }
      let(:note_2) {
        FactoryBot.create(:legacy_note,
          organization: organization,
          target: nil,
          pricings_pricing_id: pricing.id)
      }

      it "returns the itinerary title" do
        expect(decorated_note_json.dig("itineraryTitle")).to eq(itinerary.name)
        expect(decorated_note_2_json.dig("itineraryTitle")).to eq(itinerary.name)
      end

      it "returns the mode of transport of the itinerary" do
        expect(decorated_note_json.dig("mode_of_transport")).to eq(itinerary.mode_of_transport)
        expect(decorated_note_json.dig("mode_of_transport")).to eq(itinerary.mode_of_transport)
      end

      it "returns the service level if the pricing is set" do
        expect(decorated_note_2_json.dig("service")).to eq(tenant_vehicle.full_name)
      end
    end
  end
end
