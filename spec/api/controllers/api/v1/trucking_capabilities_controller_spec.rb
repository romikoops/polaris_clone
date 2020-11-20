# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::TruckingCapabilitiesController, type: :controller do
    routes { Engine.routes }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:user) { FactoryBot.create(:users_user, email: "test@example.com", organization_id: organization.id) }

    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:params) { {load_type: "cargo_item", organization_id: organization.id} }

    describe "GET #index" do
      context "when origin and destination have no trucking" do
        before do
          request.headers["Authorization"] = token_header
          get :index, params: params, as: :json
        end

        it "returns falsy result for origin and destination" do
          aggregate_failures do
            expect(response_data["origin"]).to be_falsy
            expect(response_data["destination"]).to be_falsy
          end
        end
      end

      context "when trucking is available only on the origin" do
        before do
          FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
          request.headers["Authorization"] = token_header
          get :index, params: params, as: :json
        end

        it "returns truthy for origin, falsy for destination" do
          aggregate_failures do
            expect(response_data["origin"]).to be_truthy
            expect(response_data["destination"]).to be_falsy
          end
        end
      end

      context "when trucking is available only on the destination" do
        before do
          FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
          request.headers["Authorization"] = token_header
          get :index, params: params, as: :json
        end

        it "returns falsy for the origin and truthy for the destination" do
          aggregate_failures do
            expect(response_data["origin"]).to be_falsy
            expect(response_data["destination"]).to be_truthy
          end
        end
      end

      context "when trucking is available on both sides" do
        before do
          FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
          FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, custom_truck_type: "default2",
                                                           query_type: :location)
          request.headers["Authorization"] = token_header
          get :index, params: params, as: :json
        end

        it "returns truthy for origin and destination" do
          aggregate_failures do
            expect(response_data["origin"]).to be_truthy
            expect(response_data["destination"]).to be_truthy
          end
        end
      end
    end
  end
end
