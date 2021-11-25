# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Results", type: :request, swagger: true do
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: client.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:query) { FactoryBot.create(:journey_query, organization: organization, client: client) }
  let(:result) { FactoryBot.create(:journey_result, query: query) }

  before { FactoryBot.create(:routing_carrier, with_logo: true, name: result.route_sections.first.carrier) }

  path "/v2/organizations/{organization_id}/queries/{query_id}/results" do
    get "Fetch Results for the query" do
      tags "Results"
      description "Fetch Results for the query"
      operationId "getResults"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"
      parameter name: :query_id, in: :path, type: :string, description: "Query ID"

      let(:organization_id) { organization.id }
      let(:query_id) { query.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { "$ref" => "#/components/schemas/restfulResponse" }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/results/{id}" do
    get "Fetch Result" do
      tags "Results"
      description "Fetch Result"
      operationId "getResult"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"
      parameter name: :id, in: :path, type: :string, description: "Result ID"

      let(:organization_id) { organization.id }
      let(:id) { result.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: { "$ref" => "#/components/schemas/result" },
               required: ["data"]

        run_test!
      end
    end
  end
end
