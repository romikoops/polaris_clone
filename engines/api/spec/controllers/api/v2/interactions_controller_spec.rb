# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::InteractionsController, type: :controller do
    routes { Engine.routes }
    before do
      request.headers["Authorization"] = "Bearer #{access_token.token}"
      tracker_interaction
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:users_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: users_client.id, scopes: "public") }
    let(:tracker_interaction) { Tracker::Interaction.create(name: "tutorial", organization: organization) }

    describe "#index" do
      let(:params) { { organization_id: organization.id } }

      context "with valid params" do
        it "returns success (200)" do
          get :index, params: params
          expect(response).to have_http_status(:ok)
        end

        it "returns all interactions performed by the logged in user" do
          get :index, params: params
          expect(response_json).to eq({ "data" => ["tutorial"] })
        end
      end
    end
  end
end
