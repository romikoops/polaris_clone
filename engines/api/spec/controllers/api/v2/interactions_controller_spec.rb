# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::InteractionsController, type: :controller do
    routes { Engine.routes }
    before do
      request.headers["Authorization"] = "Bearer #{access_token.token}"
      FactoryBot.create(:organizations_domain, organization: organization, domain: "test.itsmycargo.com", default: false)
      request.headers["Referer"] = "http://test.itsmycargo.com"
      tracker_interaction
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:users_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: users_client.id, scopes: "public") }
    let(:tracker_interaction) { Tracker::Interaction.create(name: "tutorial") }

    describe "#index" do
      context "with valid params" do
        it "returns success (200)" do
          get :index
          expect(response).to have_http_status(:ok)
        end

        it "returns all interactions performed by the logged in user" do
          get :index
          expect(response_data.pluck("name")).to match_array(["tutorial"])
        end
      end
    end
  end
end
