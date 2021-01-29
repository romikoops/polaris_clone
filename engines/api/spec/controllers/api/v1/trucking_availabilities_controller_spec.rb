# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TruckingAvailabilitiesController, type: :controller do
    routes { Engine.routes }
    include_context "complete_route_with_trucking"
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user, email: "test@example.com", organization_id: organization.id) }
    let(:cargo_classes) { ["lcl"] }
    let(:load_type) { "cargo_item" }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:data) { JSON.parse(response.body) }
    let(:wrong_lat) { 10.00 }
    let(:wrong_lng) { 60.50 }

    before do
      request.headers["Authorization"] = token_header
      Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
        "address_components" => [{"types" => ["premise"]}],
        "address" => "Helsingborg, Sweden",
        "city" => "Gothenburg",
        "country" => "Sweden",
        "country_code" => "SE",
        "postal_code" => "43822"
      ])
      allow(controller).to receive(:current_organization).at_least(:once).and_return(organization)
    end

    context "without user" do
      describe "GET #index" do
        let(:lat) { pickup_address.latitude }
        let(:lng) { pickup_address.longitude }

        context "when trucking is available" do
          before do
            params = {lat: lat, lng: lng, load_type: "cargo_item", organization_id: organization.id, target: "origin"}
            get :index, params: params, as: :json
          end

          it "returns available trucking options" do
            aggregate_failures do
              expect(response).to be_successful
              expect(data["truckingAvailable"]).to eq true
              expect(data["truckTypes"]).to eq(["default"])
            end
          end
        end

        context "when trucking is not available" do
          before do
            params = {lat: wrong_lat, lng: wrong_lng, load_type: "container", organization_id: organization.id,
                      target: "destination"}
            get :index, params: params, as: :json
          end

          it "returns empty keys when no trucking is available" do
            aggregate_failures do
              expect(response).to be_successful
              expect(data["truckingAvailable"]).to eq false
              expect(data["truckTypes"]).to be_empty
            end
          end
        end
      end
    end

    context "with user" do
      let(:group_client) { FactoryBot.create(:users_client, organization: organization) }
      let(:no_group_client) { FactoryBot.create(:users_client, organization: organization) }
      let(:group) {
        FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: group_client, group: tapped_group)
        end
      }

      before do
        Trucking::Trucking.update_all(group_id: group.id)
      end

      describe "GET #index" do
        let(:lat) { pickup_address.latitude }
        let(:lng) { pickup_address.longitude }

        context "when trucking is available for the group of that user" do
          before do
            params = {lat: lat, lng: lng, load_type: "cargo_item", organization_id: organization.id,
                      target: "origin", client: group_client}
            get :index, params: params, as: :json
          end

          it "returns available trucking options" do
            aggregate_failures do
              expect(response).to be_successful
              expect(data["truckingAvailable"]).to eq true
              expect(data["truckTypes"]).to eq(["default"])
            end
          end
        end

        context "when trucking is not available for given user" do
          before do
            params = {lat: lat, lng: lng, load_type: "cargo_item", organization_id: organization.id,
                      target: "origin", client: no_group_client}
            get :index, params: params, as: :json
          end

          it "returns empty keys when no trucking is available" do
            aggregate_failures do
              expect(response).to be_successful
              expect(data["truckingAvailable"]).to eq false
              expect(data["truckTypes"]).to be_empty
            end
          end
        end
      end
    end
  end
end
