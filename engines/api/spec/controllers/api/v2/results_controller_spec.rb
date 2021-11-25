# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ResultsController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:query) { FactoryBot.create(:journey_query, client: user, result_count: 1, organization: organization) }
    let(:params) { { query_id: query.id, organization_id: organization.id } }

    before do
      request.headers["Authorization"] = token_header
      allow(::Routing::Carrier).to receive(:find_by).and_return(FactoryBot.build(:routing_carrier))
    end

    describe "GET #index" do
      it "successfully returns the Result ids for the given ResultSet" do
        get :index, params: params, as: :json
        expect(response_data.pluck("id")).to match_array(query.results.ids)
      end

      context "when Query does not belong to current Organization" do
        let(:query) { FactoryBot.create(:journey_query, result_count: 1) }

        it "return 401 unauthorized" do
          get :index, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when Query does not belong to current user" do
        let(:query) { FactoryBot.create(:journey_query, result_count: 1, organization: organization) }

        it "return 401 unauthorized" do
          get :index, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when request is unauthed and query has client" do
        let(:query) { FactoryBot.create(:journey_query, result_count: 1, organization: organization) }
        let(:token_header) { "" }

        it "return 401 unauthorized" do
          get :index, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when request is unauthed and query has no client" do
        let(:query) { FactoryBot.create(:journey_query, client: nil, result_count: 1, organization: organization) }
        let(:token_header) { "" }

        it "returns the Results belonging to the Query" do
          get :index, params: params, as: :json
          expect(response_data.pluck("id")).to match_array(query.results.ids)
        end
      end
    end

    describe "GET #show" do
      let(:result) { query.results.first }
      let(:params) { { id: result.id, organization_id: organization.id } }

      it "returns the correct result id" do
        get :show, params: params, as: :json
        expect(response_data["id"]).to eq(result.id)
      end

      context "with voyage_info.transit_time set to true" do
        before do
          organization.scope.update(content: { voyage_info: { transit_time: true } })
        end

        let(:result) { FactoryBot.create(:journey_result, sections: 0, query: query, route_sections: [FactoryBot.build(:journey_route_section, mode_of_transport: "ocean", transit_time: 12)]) }

        it "returns the transit time in the response" do
          get :show, params: params, as: :json
          expect(response_data.dig("attributes", "transitTime")).to eq(12)
        end
      end

      context "when result does not belong to current Organization" do
        let(:query) { FactoryBot.create(:journey_query, result_count: 1) }

        it "return 401 unauthorized" do
          get :show, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when result does not belong to current user" do
        let(:query) { FactoryBot.create(:journey_query, result_count: 1, organization: organization) }

        it "return 401 unauthorized" do
          get :show, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when request is unauthed and result has client" do
        let(:query) { FactoryBot.create(:journey_query, result_count: 1, organization: organization) }
        let(:token_header) { "" }

        it "return 401 unauthorized" do
          get :show, params: params, as: :json
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when request is unauthed and result has no client" do
        let(:query) { FactoryBot.create(:journey_query, client: nil, result_count: 1, organization: organization) }
        let(:token_header) { "" }

        it "returns the Result" do
          get :show, params: params, as: :json
          expect(response_data["id"]).to eq(result.id)
        end
      end
    end
  end
end
