# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::UsersInteractionsController, type: :controller do
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
      let(:params) { { organization_id: organization.id } }

      context "with valid params" do
        before do
          Tracker::UsersInteraction.create(interaction: tracker_interaction, client: users_client)
        end

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

    describe "#create" do
      before { post :create, params: params }

      let(:params) { { organization_id: organization.id, userInteraction: { interactionName: "tutorial" } } }

      context "with valid params" do
        it "returns created (201)" do
          expect(response).to have_http_status(:created)
        end

        it "returns success true as a part of response" do
          expect(response_json).to eq({ "success" => true })
        end
      end

      context "when interaction is not found" do
        let(:params) { { organization_id: organization.id, userInteraction: { interactionName: "invalid" } } }

        it "returns unprocessable_entity (422)" do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns valid error code" do
          expect(response_json["error_code"]).to eq "undefined_interaction"
        end
      end
    end
  end
end
