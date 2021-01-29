# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::OrganizationsController, type: :controller do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:json_response) { JSON.parse(response.body) }

  before do
    ::Organizations.current_id = organization.id
    append_token_header
  end

  describe "POST #update" do
    let(:email_params) { {"sales" => {"ocean" => "new_ocean@sales.com"}} }

    it "returns http success" do
      put :update, params: {
        organization_id: organization.id,
        id: organization.id,
        tenant: {emails: email_params}
      }
      expect(response).to have_http_status(:success)
    end

    it "updates organization emails" do
      put :update, params: {
        organization_id: organization.id,
        id: organization.id,
        tenant: {emails: email_params}
      }
      expect(organization.theme.emails["ocean"]).to match email_params["ocean"]
    end
  end
end
