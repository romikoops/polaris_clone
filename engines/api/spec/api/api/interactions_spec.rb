# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Interactions", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user_client.id, scopes: "public") }

  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v2/organizations/{organization_id}/interactions" do
    get "Fetch all interactions for an organization" do
      tags "Interaction (V2)"
      description "Fetch interaction information for a given organization"
      operationId "createUsersInteraction"

      security [bearerAuth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { type: :string }
            }
          },
          required: ["data"]
        run_test!
      end

      response "401", "Unauthorized request" do
        let(:Authorization) { "Token token=WRONG" }

        run_test!
      end
    end
  end
end
