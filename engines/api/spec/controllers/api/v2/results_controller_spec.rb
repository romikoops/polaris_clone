# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ResultsController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:query) { FactoryBot.create(:journey_query, result_count: 1) }
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
    end

    describe "GET #show" do
      let(:result) { query.results.first }
      let(:params) { { id: result.id, organization_id: organization.id } }

      it "returns the correct result id" do
        get :show, params: params, as: :json
        expect(response_data["id"]).to eq(result.id)
      end

      context "with support for result set id" do
        let(:params) { { result_set_id: query.id, id: result.id, organization_id: organization.id } }

        it "returns the correct result id" do
          get :show, params: params, as: :json
          expect(response_data["id"]).to eq(result.id)
        end
      end
    end
  end
end
