# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Errors", type: :request, swagger: true do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:query) { FactoryBot.create(:journey_query) }

  path "/v2/organizations/{organization_id}/queries/{query_id}/errors" do
    get "Fetch Errors for the Result Set" do
      tags "Users"
      description "Fetch errors for the given result set."
      operationId "getResultSetErrors"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"
      parameter name: :query_id, in: :path, type: :string, description: "Query ID"

      let(:organization_id) { organization.id }
      let(:query_id) { query.id }
      before { FactoryBot.create(:journey_error, query: query) }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { "$ref" => "#/components/schemas/journeyError" }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
