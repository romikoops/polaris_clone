# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Scopes", type: :request, swagger: true do
  let(:user) { FactoryBot.create(:users_user) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v2/organizations/{organization_id}/scope" do
    get "Fetch Scope for the Organization" do
      tags "Scope"
      description "Fetch Scope for the Organization"
      operationId "getScope"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "Organization ID"

      let(:organization_id) { organization.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {"$ref" => "#/components/schemas/scope"}
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
