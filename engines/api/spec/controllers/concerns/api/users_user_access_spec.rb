# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe "UsersUserAccess" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "#authorize_users_user" do
      before do
        request.headers["Authorization"] = token_header
        allow(controller).to receive(:current_user) { user }
      end

      controller(ApplicationController) do
        include UsersUserAccess
        def index
          render json: []
        end
      end

      context "when current user is users user" do
        before { get :index, as: :json }

        it "returns unauthorized response" do
          expect(response).to have_http_status(:success)
        end
      end

      context "when current user is not users user" do
        let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }

        before { get :index, as: :json }

        it "returns unauthorized response" do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
