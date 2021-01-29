# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Authentication by token", type: :request do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }

  context "user logged out" do
    it "responds correctly, requiring authentication" do
      get organization_user_home_path(organization_id: organization.id, user_id: user.id)

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "user logged in" do
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:headers) { {"Authorization": "Bearer " + access_token.token} }

    it "shows user home page" do
      get organization_user_home_path(organization_id: organization.id, user_id: user.id), headers: headers
      expect(controller.send(:current_user)).to eq(user)
    end
  end
end
