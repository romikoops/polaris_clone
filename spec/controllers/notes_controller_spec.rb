# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotesController, type: :controller do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }

  before do
    FactoryBot.create(:legacy_note, target: itinerary, tenant: tenant)
    FactoryBot.create(:legacy_note, tenant: tenant)
  end

  describe "GET #index" do
    it "returns the notes for the itinerary" do
      get :index, params: {itineraries: [itinerary.id], tenant_id: tenant.id}
      json_response = JSON.parse(response.body)
      aggregate_failures do
        expect(response).to have_http_status(:success)
        expect(json_response["data"].length).to eq(1)
      end
    end
  end
end
