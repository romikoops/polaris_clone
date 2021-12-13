# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::ItinerariesController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization) }

    describe "GET #itineraries" do
      let(:user) { FactoryBot.create(:users_user) }
      let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
      let(:token_header) { "Bearer #{access_token.token}" }

      before do
        request.headers["Authorization"] = token_header
        FactoryBot.create(:users_membership, organization: organization, user: user)
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Ningbo - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Shanghai - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Qingdao - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Bangkok - Gothenburg")
        FactoryBot.create(:legacy_itinerary, organization: organization, name: "Tokyo - Gothenburg")
        get :index, params: { organization_id: organization.id }, as: :json
      end

      it "has a successful respoonse" do
        expect(response).to be_successful
      end

      it "returns a list of itineraries belonging to the organization" do
        expect(response_data.length).to eq(5)
      end
    end
  end
end
