# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::LocationsController, type: :controller do
    routes { Engine.routes }
    include_context "complete_route_with_trucking"

    before do
      request.headers["Authorization"] = token_header
      ::Organizations.current_id = organization.id
    end

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:user) { FactoryBot.create(:users_client, email: "test@example.com", organization_id: organization.id) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:origin_nexus) { origin_hub.nexus }
    let(:destination_nexus) { destination_hub.nexus }
    let(:load_type) { "cargo_item" }
    let(:cargo_classes) { ["lcl"] }

    describe "GET #origins" do
      it "Renders a json of origins for given a destination id" do
        FactoryBot.create(:felixstowe_shanghai_itinerary, organization_id: organization.id)
        FactoryBot.create(:hamburg_shanghai_itinerary, organization_id: organization.id)

        get :origins, params: {organization_id: organization.id, id: destination_hub.nexus_id, load_type: load_type}

        origins = Legacy::Itinerary.where(organization: organization).map { |itin| itin.first_nexus.name }
        expect(response_data.map { |origin| origin.dig("attributes", "name") }).to match_array(origins)
      end

      it "Renders a json of origins when query matches origin" do
        get :origins, params: {organization_id: organization.id, q: "Goth", load_type: load_type}

        expect(response_data[0]["attributes"]["name"]).to eq(origin_nexus.name)
      end

      it "Renders an array of all origins when location params are empty" do
        get :origins, params: {organization_id: organization.id}
        expect(response_data[0]["attributes"]["name"]).to eq(origin_nexus.name)
      end
    end

    describe "GET #destinations" do
      let(:origin_location) do
        FactoryBot.create(:locations_location,
          bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
          country_code: origin_hub.country.code.downcase)
      end
      let(:origin_trucking_location) {
        FactoryBot.create(:trucking_location, :with_location, location: origin_location, country: origin_hub.country)
      }

      it "Renders a json of destinations for a given a origin id" do
        get :destinations, params: {organization_id: organization.id, id: origin_hub.nexus_id, load_type: load_type}

        expect(response_data[0]["attributes"]["name"]).to eq(destination_nexus.name)
      end

      it "Renders a json of destinations for a given coordinates" do
        get :destinations, params: {
          organization_id: organization.id, lat: pickup_address.latitude, lng: pickup_address.longitude,
          load_type: load_type
        }

        expect(response_data[0]["attributes"]["name"]).to eq(destination_nexus.name)
      end

      it "Renders a json of destinations when query matches destination name" do
        get :destinations, params: {
          organization_id: organization.id,
          q: destination_nexus.name[0..3],
          load_type: load_type
        }

        expect(response_data[0]["attributes"]["name"]).to eq(destination_nexus.name)
      end

      it "Renders an array of all destinations when location params are empty" do
        get :destinations, params: {organization_id: organization.id}

        expect(response_data[0]["attributes"]["name"]).to eq(destination_nexus.name)
      end
    end
  end
end
