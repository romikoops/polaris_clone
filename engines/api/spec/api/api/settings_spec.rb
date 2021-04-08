# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Settings", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    Organizations.current_id = organization.id
  end

  path "/v1/me/settings" do
    get "Fetch user settings" do
      tags "Users"
      description <<~DOC
        Fetch current settings for the current user. Settings contains information about user's preferred language and
        locale.
      DOC
      operationId "getSettings"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      response 200, "successful operation" do
        schema type: :object,
               properties: {
                 data: { "$ref" => "#/components/schemas/settings" }
               },
               required: ["data"]

        run_test!
      end

      response 401, "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end
end
