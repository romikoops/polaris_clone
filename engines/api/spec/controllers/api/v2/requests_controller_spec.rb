# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::RequestsController, type: :controller do
    routes { Engine.routes }
    ActiveJob::Base.queue_adapter = :test

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:companies_membership, client: user)
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
    let(:source) { FactoryBot.create(:application, name: "siren") }
    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public", application: source) }
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "POST #create" do
      let(:query) { FactoryBot.create(:journey_query, organization: organization) }
      let(:params) { { query_id: query.id, organization_id: organization.id, modeOfTransport: "ocean" } }

      it "successfully creates the event", :aggregate_failures do
        post :create, params: params, as: :json
        expect(response.status).to eq(200)
      end
    end
  end
end
