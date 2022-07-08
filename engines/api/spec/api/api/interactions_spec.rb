# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Interactions", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user_client.id, scopes: "public") }

  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:Referer) { "http://siren-sir-1337.itsmycargo.dev" }

  before do
    FactoryBot.create(:organizations_domain, organization: organization, domain: "siren-%.itsmycargo.dev", default: false)
    ::Organizations.current_id = organization_id
  end

  path "/v2/interactions" do
    get "Fetch all interactions for an organization" do
      tags "Interaction (V2)"
      description "Fetch interaction information for a given organization"
      operationId "createUsersInteraction"

      security [bearerAuth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :Referer, in: :header, type: :string, description: "HTTP Referrer from which the host/domain information will be extracted"

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: {
                    type: :UUID,
                    description: "ID of the interaction"
                  },
                  name: {
                    type: :string,
                    description: "Name of the interaction"
                  },
                  created_at: {
                    type: :string,
                    description: "Interaction creation time"
                  },
                  updated_at: {
                    type: :string,
                    description: "Interaction updation time"
                  }
                }
              }
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
