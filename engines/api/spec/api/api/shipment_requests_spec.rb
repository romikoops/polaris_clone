# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "ShipmentRequests", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:shipment_request_id) { "SR12345" }

  before do
    Organizations.current_id = organization_id
    FactoryBot.create(:companies_company, organization: organization, name: "default")
  end

  path "/v2/organizations/{organization_id}/shipment_requests/{shipment_request_id}" do
    get "Fetch a shipment request" do
      tags "ShipmentRequests"
      description "Fetch a specific shipment request"
      operationId "getShipmentRequesrt"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :shipment_request_id, in: :path, type: :string, description: "The shipment request ID"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     attributes: { "$ref" => "#/components/schemas/shipment_request" }
                   }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/shipment_requests" do
    post "Create a shipment request" do
      tags "ShipmentRequests"
      description "Create a shipment request"
      operationId "createShipmentRequest"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :shipment_request_id, in: :path, type: :string, description: "The shipment request ID"

      parameter name: :shipment_request, in: :body, schema: {
        type: :object,
        properties: {
          result_id: { type: :string, description: "The Journey result id" },
          additional_requirements: { type: :string, description: "Additional requirements for the shipment" },
          customs: { type: :boolean, description: "Any customs handling service needed" },
          insurance: { type: :boolean, description: "Any insurance on the cargo" },
          commercial_value: { type: :string, description: "Cargo commercial value" },
          contact: {
            type: :object,
            description: "Contact info for client",
            properties: {
              name: { type: :string, description: "Client name" },
              phone: { type: :string, description: "Client phone number" },
              email: { type: :string, description: "Client email" },
              additional_information: { type: :string, description: "Additional information about the client" }
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:shipment_request) do
          {
            result_id: "RESULT_ID_12345",
            additional_requirements: "Some additional requirements",
            customs: true,
            insurance: true,
            commercial_value: "100",
            contact: {
              name: "John",
              email: "foo@bar.com",
              phone: "112233",
              additional_information: "Some additional info"
            }
          }
        end

        schema type: :object,
               properties: {
                 data: {
                   preferred_voyage: "FOO"
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
