# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Profiles", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:companies_membership, client: client)
    Organizations.current_id = organization_id
  end

  path "/v2/organizations/{organization_id}/profile" do
    get "Fetch client profile" do
      tags "Profiles"
      description "Retrieve user's profile. User's profile includes additional information besides email that are used usually to better display user information, has more detailed contact information etc.
      User profile includes name (as first name, and last name) which can be used for display purposes."
      operationId "getProfile"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

      response 200, "successful operation" do
        schema type: :object,
               properties: {
                 data: { "$ref" => "#/components/schemas/profile" }
               },
               required: ["data"]

        run_test!
      end

      response 401, "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end

    patch "Update" do
      tags "Profiles"
      description "Update profile details."
      operationId "updateProfile"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :profile, in: :body, schema: {
        type: :object,
        properties: {
          profile: {
            type: "object",
            properties: {
              email: {
                description: "The new email of the client",
                type: "string",
                pattern: "email",
                nullable: true
              },
              firstName: {
                description: "First name of the user",
                type: "string",
                nullable: true
              },
              lastName: {
                description: "Last name of the user",
                type: "string",
                nullable: true
              },
              currency: {
                description: "ISO 4217 3 letter currency code",
                type: "string",
                nullable: true
              },
              language: {
                description: "Language code eg. en-US",
                type: "string",
                nullable: true
              },
              locale: {
                description: "Localization format eg. en-US",
                type: "string",
                nullable: true
              },
              password: {
                description: "A new password for the user account",
                type: "string",
                minLength: 8,
                nullable: true
              }
            }
          }
        },
        required: ["profile"]
      }
      let(:profile) do
        {
          profile: {
            email: "john@example.com",
            firstName: "John",
            lastName: "Doe",
            currency: nil,
            language: nil,
            locale: nil
          }
        }
      end
      let(:id) { client.profile.id }

      response 200, "successful operation" do
        run_test!
      end

      response 422, "Unprocessable Entity" do
        let(:profile) do
          {
            profile: { email: FactoryBot.create(:users_client, organization: organization).email }
          }
        end

        run_test!
      end
    end
  end
end
