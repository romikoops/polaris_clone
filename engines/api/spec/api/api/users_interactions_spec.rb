# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "UsersInteractions", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:organization_id) { organization.id }
  let(:user_client) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user_client.id, scopes: "public") }
  let(:tracker_interaction) { Tracker::Interaction.create(name: "tutorial") }
  let(:Referer) { "http://siren-sir-1337.itsmycargo.dev" }

  before do
    FactoryBot.create(:organizations_domain, organization: organization, domain: "siren-%.itsmycargo.dev", default: false)
    Tracker::UsersInteraction.create(interaction: tracker_interaction, client: user_client)
  end

  path "/v2/users_interactions" do
    post "creates users interaction" do
      tags "UsersInteraction (V2)"
      description "Create a new Users Interaction"
      operationId "createUsersInteraction"

      security [bearerAuth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :Referer, in: :header, type: :string, description: "HTTP Referrer from which the host/domain information will be extracted"
      parameter name: :users_interaction_params, in: :body, schema: {
        type: :object,
        properties: {
          interaction_name: {
            type: :string,
            description: "Provides the interactionName after interaction performed by the logged in user"
          }
        }
      }, required: true

      let(:users_interaction_params) { { userInteraction: { interactionName: "tutorial" } } }

      response "201", "Successful operation" do
        run_test!
      end

      response "401", "Unauthorized request" do
        let(:Authorization) { "Token token=WRONG" }

        run_test!
      end

      response "422", "invalid request (invalid interaction name)" do
        let(:users_interaction_params) { { userInteraction: { interactionName: "invalid" } } }

        run_test!
      end
    end

    get "Fetch all interactions for an organization" do
      tags "Interaction (V2)"
      description "Fetch interaction information for a given organization and current user"
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
