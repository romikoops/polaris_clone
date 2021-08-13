# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Requests", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization)
  end

  path "/v2/organizations/{organization_id}/queries/{query_id}/requests" do
    let(:organization_id) { organization.id }
    let(:query_id) { query.id }
    let(:modeOfTransport) { "ocean" }

    post "Create a Request" do
      tags "Quote"
      description "Creates a Journey::Request with the provided information"
      operationId "createRequest"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :query_id, in: :path, type: :string, description: "The current ID of the Journey::Query you wish to make a Request over."
      parameter name: :modeOfTransport, in: :body, type: :string, description: "The preferred mode of transport for the Request"

      response "200", "successful operation" do
        run_test!
      end
    end
  end
end
