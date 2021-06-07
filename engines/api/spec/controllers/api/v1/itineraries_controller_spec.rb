# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ItinerariesController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization) }

    describe "GET #itineraries" do
      let(:user) { FactoryBot.create(:users_client, email: "test@example.com", organization: organization) }
      let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
      let(:token_header) { "Bearer #{access_token.token}" }
      let(:itinerary_subject) do
        request.headers["Authorization"] = token_header
        request_object
      end

      let(:request_object) do
        get :index, params: {organization_id: organization.id}, as: :json
      end

      before do
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Ningbo - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Shanghai - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Qingdao - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Bangkok - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Tokyo - Gothenburg")
      end

      it "has a successful respoonse" do
        expect(response).to be_successful
      end

      it "returns a list of itineraries belonging to the organization" do
        data = JSON.parse(itinerary_subject.body)
        expect(data["data"].length).to eq(5)
      end
    end
  end
end
