# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiAuth::TokensController, type: :request do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:email) { "agent@itsmycargo.com" }
  let(:password) { "IMC123456789" }
  let(:application) { FactoryBot.create(:application) }
  let(:params) do
    { email: user.email,
      password: password,
      organization_id: organization.id,
      grant_type: "password",
      client_id: application.uid,
      client_secret: application.secret }
  end

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200)
  end

  shared_examples "Successful login" do
    it "generates new token", :aggregate_failures do
      post "/oauth/token", params: params

      expect(response).to have_http_status(:success)
    end
  end

  describe "bad_request" do
    let(:user) { FactoryBot.create(:users_client) }

    it "returns bad_request" do
      post "/oauth/token", params: params

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "authorized" do
    let(:new_token) { Doorkeeper::AccessToken.find_by(resource_owner_id: user.id, scopes: "public") }

    context "when organization user" do
      let(:user) do
        FactoryBot.create(:users_client,
          organization_id: organization.id, email: email, password: password)
      end

      it_behaves_like "Successful login"
    end

    context "when the email is not lowercased" do
      let(:email) { "AGENT@itsmycargo.com" }
      let(:user) do
        FactoryBot.create(:users_client,
          organization_id: organization.id, email: email, password: password)
      end

      it_behaves_like "Successful login"
    end

    context "when admin user" do
      let(:user) do
        FactoryBot.create(:users_user, email: email, password: password).tap do |user|
          FactoryBot.create(:users_membership, organization: organization, user: user, role: :admin)
        end
      end

      before do
        allow(::Organizations::Organization).to receive(:current_id).and_return(organization.id)
      end

      it_behaves_like "Successful login"
    end
  end
end
