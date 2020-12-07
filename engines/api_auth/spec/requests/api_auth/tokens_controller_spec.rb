# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiAuth::TokensController, type: :request do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:email) { "agent@itsmycargo.com" }
  let(:password) { "IMC123456789" }
  let(:params) do
    {"email": user.email,
     "password": password,
     "organization_id": organization.id,
     "grant_type": "password"}
  end

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200)
  end

  describe "unauthorized" do
    let(:user) { FactoryBot.create(:authentication_user) }

    it "should return unauthorized" do
      post "/oauth/token", params: params

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "authorized" do
    let(:new_token) { Doorkeeper::AccessToken.find_by(resource_owner_id: user.id, scopes: "public") }

    context "when organization user" do
      let!(:user) {
        FactoryBot.create(:authentication_user,
          :organizations_user, activation_state: "active",
                               organization_id: organization.id, email: email, password: password)
      }

      it "generates new token" do
        post "/oauth/token", params: params

        expect(JSON.parse(response.body)["access_token"]).to eq new_token.token
        expect(new_token).to be_valid
      end
    end

    context "when admin user" do
      let(:user) do
        FactoryBot.create(:authentication_user, :users_user, activation_state: "active",
                                                             email: email, password: password).tap do |user|
          FactoryBot.create(:organizations_membership, organization: organization, user: user)
        end
      end

      before do
        allow(::Organizations::Organization).to receive(:current_id).and_return(organization.id)
      end

      it "generates new token" do
        post "/oauth/token", params: params

        expect(JSON.parse(response.body)["access_token"]).to eq new_token.token
        expect(new_token).to be_valid
      end
    end
  end
end
