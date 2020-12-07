# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::OrganizationsController, type: :controller do
    routes { Engine.routes }
    before do
      request.headers["Authorization"] = token_header
      request.env["HTTP_REFERER"] = "http://itsmycargo.example"
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_user) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:scope) { OrganizationManager::ScopeService.new(organization: organization, target: user).fetch }

    describe "GET #index" do
      before do
        FactoryBot.create(:organizations_membership, organization: organization, user: user)
      end

      it "renders the list of organizations successfully" do
        get :index, as: :json
        aggregate_failures do
          expect(response_data[0]["attributes"]["slug"]).to eq(organization.slug)
          expect(response_data[0]["attributes"]["name"]).to eq(organization.theme.name)
        end
      end
    end

    describe "GET #scope" do
      it "renders the scope of the requested organization succeessfully" do
        get :scope, params: {id: organization.id}, as: :json

        expect(response_json).to match(scope)
      end
    end
  end
end
