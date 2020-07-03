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
  end
end
