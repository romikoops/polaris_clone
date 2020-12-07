# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::UsersController, type: :controller do
    routes { Engine.routes }

    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:user) { FactoryBot.create(:organizations_user) }

    before do
      FactoryBot.create(:profiles_profile, user_id: user.id)

      request.headers["Authorization"] = token_header
      request.env["HTTP_REFERER"] = "http://itsmycargo.example"
    end

    describe "Get #show" do
      context "when user is present" do
        it "returns the requested client correctly" do
          get :show

          expect(response).to be_successful
        end
      end

      context "when id is wrong" do
        let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: "wrong_id", scopes: "public") }

        it "returns 404" do
          get :show

          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
