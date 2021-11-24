# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::UsersController, type: :controller do
    routes { Engine.routes }

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user, organization_id: organization.id) }
    let(:email) { "shopadmin@itsmycargo.com" }

    describe "#validate" do
      before { FactoryBot.create(:users_membership, organization: organization, user: user) }

      context "when user with the specified email is exists" do
        it "returns a 200 OK response" do
          get :validate, params: { email: user.email }, as: :json
          expect(response).to have_http_status(:ok)
        end

        it "returns first name of the user" do
          get :validate, params: { email: user.email }, as: :json
          expect(response_data["attributes"]["firstName"]).to eq user.profile.first_name
        end

        it "returns auth methods for the user" do
          get :validate, params: { email: user.email }, as: :json
          expect(response_data["attributes"]["authMethods"]).to eq ["password"]
        end
      end

      context "when email is not passed as query param" do
        it "returns bad request" do
          expect { get :validate, params: {}, as: :json }.to raise_error(ActionController::ParameterMissing)
        end
      end

      context "when user with the specified email is not found" do
        it "returns not found" do
          get :validate, params: { email: "test@example.com" }, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
