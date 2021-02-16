# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "CargoUnits", type: :request, swagger_doc: "v2/swagger.json" do
  let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:query) { FactoryBot.build(:journey_query, organization: organization, client: user, cargo_units: []) }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v2/organizations/{organization_id}/queries/{query_id}/cargo_units" do
    get "Fetch CargoUnits for the Query" do
      tags "CargoUnits"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, schema: {type: :string}, description: "Organization ID"
      parameter name: :query_id, in: :path, type: :string, schema: {type: :string}, description: "Query ID"

      let(:organization_id) { organization.id }
      let!(:cargo_units) {
        FactoryBot.create_list(:journey_cargo_unit, 3, query: query)
      }
      let(:query_id) { query.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/item"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/queries/{query_id}/cargo_units/{id}" do
    get "Fetch CargoUnit for the Query" do
      tags "CargoUnits"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, schema: {type: :string}, description: "Organization ID"
      parameter name: :query_id, in: :path, type: :string, schema: {type: :string}, description: "Query ID"
      parameter name: :id, in: :path, type: :string, schema: {type: :string}, description: "CargoUnit ID"

      let(:organization_id) { organization.id }
      let!(:cargo_unit) { FactoryBot.create(:journey_cargo_unit, query: query) }
      let(:id) { cargo_unit.id }
      let(:query_id) { query.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {"$ref" => "#/components/schemas/item"}
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
