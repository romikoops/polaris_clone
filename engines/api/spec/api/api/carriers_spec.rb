# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Carriers", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:client) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:groups_group) { Groups::Group.create(organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: client.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before { FactoryBot.create_list(:routing_carrier, 5) }

  path "/v2/organizations/{organization_id}/carriers" do
    get "Fetch all available carriers" do
      tags "Carriers"
      description "Fetches all possible carriers enabled for the customer."
      operationId "getCarriers"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { "$ref" => "#/components/schemas/carrier" }
                 }
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/carriers/{id}" do
    get "Fetch carrier" do
      tags "Carriers"
      description "Fetches a specific Carrier."
      operationId "getCarrier"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "The ID of the Carrier"

      let(:id) { FactoryBot.create(:routing_carrier).id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: { "$ref" => "#/components/schemas/carrier" }
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end
end
