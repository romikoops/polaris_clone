# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }

  before do
    FactoryBot.create(:legacy_note, target: itinerary, organization: organization)
    FactoryBot.create(:legacy_note, organization: organization)
  end

  describe "GET #index" do
    it "returns the notes for the itinerary" do
      get :index, params: {itineraries: [itinerary.id], organization_id: organization.id}
      json_response = JSON.parse(response.body)
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response["data"].length).to eq(1)
      end
    end

    context "when requesting for notes without targets" do
      let(:organization_2) { FactoryBot.create(:organizations_organization) }
      let(:itinerary_2) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly") }
      let(:pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary_2) }

      before do
        FactoryBot.create(:legacy_note,
          organization: organization_2,
          target: nil,
          pricings_pricing_id: pricing.id)
      end

      it "returns the notes for the itinerary" do
        get :index, params: {organization_id: organization_2.id, itineraries: [itinerary_2.id]}
        json_response = JSON.parse(response.body)
        aggregate_failures do
          expect(json_response["data"].first.dig("pricings_pricing_id")).to eq(pricing.id)
        end
      end
    end
  end
end
