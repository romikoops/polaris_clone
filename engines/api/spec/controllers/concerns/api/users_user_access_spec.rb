# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe "UsersUserAccess" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    shared_examples_for "unauthorized for non users user" do
      it "returns unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    describe "#authorize_users_user" do
      before do
        request.headers["Authorization"] = token_header
        allow(controller).to receive(:current_user) { user }
        allow(controller).to receive(:current_organization) { organization }
      end

      controller(ApiController) do
        include UsersUserAccess
        def index
          render json: []
        end
      end

      context "when current user is users user with membership to the organization" do
        before do
          FactoryBot.create(:users_membership, user: user, organization: organization)
          get :index, as: :json
        end

        it "returns successful response" do
          expect(response).to have_http_status(:success)
        end
      end

      context "when current user is users user without membership to the organization" do
        before { get :index, as: :json }

        it "returns unauthorized response" do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context "when current user is not users user" do
        let(:client) { FactoryBot.create(:users_client, organization_id: organization.id) }
        let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public") }

        before { get :index, as: :json }

        it_behaves_like "unauthorized for non users user"
      end
    end
  end
end
