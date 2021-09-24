# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "ShipmentRequests", type: :request, swagger: true do
  # rubocop:disable Naming/VariableNumber
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:shipment_request) { FactoryBot.create(:journey_shipment_request) }
  let(:shipment_request_id) { shipment_request.id }
  let(:journey_result) { FactoryBot.create(:journey_result) }
  let!(:company) { FactoryBot.create(:companies_company, organization: organization, name: "default") }

  before do
    Organizations.current_id = organization_id
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

      response "404", "not found operation" do
        let(:shipment_request_id) { "non-existent-id" }

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

      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          shipment_request: {
            type: :object,
            properties: {
              organization_id: { type: :string, description: "Organization ID" },
              result_id: { type: :string, description: "The Journey result id" },
              company_id: { type: :string, description: "ID of the company" },
              client_id: { type: :string, description: "ID of the User from the company" },
              with_insurance: { type: :boolean, description: "Any insurance on the cargo" },
              with_customs_handling: { type: :boolean, description: "Any customs handling service needed" },
              status: { type: "string", description: "Shipment requests's status" },
              preferred_voyage: { type: "string", description: "Preferred voyage" },
              notes: { type: :string, description: "notes about the shipment request" },
              commercial_value_cents: { type: :integer, description: "Commercial value as an integer" },
              commercial_value_currency: { type: :string, description: "Commercial value's currency" },
              contacts_attributes: {
                type: :array,
                description: "Contact info for client",
                items: { "$ref" => "#/components/schemas/contact" }
              }
            }
          },
          commodity_infos: {
            type: :array,
            description: "Commodity infos",
            items: { "$ref" => "#/components/schemas/commodityInfo" }
          }
        }
      }

      let(:body_params) do
        {
          shipment_request: shipment_request,
          commodity_infos: commodity_infos
        }
      end

      response "201", "successful operation" do
        let(:shipment_request) do
          {
            client_id: user.id,
            commercial_value_cents: 10,
            commercial_value_currency: "eur",
            company_id: company.id,
            notes: "Some notes",
            preferred_voyage: "1234",
            result_id: journey_result.id,
            status: "requested",
            with_customs_handling: false,
            with_insurance: false,
            contacts_attributes: [{
              address_line_1: "1 street", address_line_2: "2 street", address_line_3: "3 street", city: "Hamburg",
              company_name: "Foo GmBH", country_code: "de", email: "foo@bar.com", function: "notifyee", geocoded_address: "GEOCODE_ADDRESS_12345",
              name: "John Smith", phone: "+49123456", point: "On point", postal_code: "PC12"
            }]
          }
        end

        let(:commodity_infos) do
          [
            { description: "Description 1", hs_code: "1504.90.60.00", imo_class: "1" },
            { description: "Description 2", hs_code: "2504.90.60.00", imo_class: "2" }
          ]
        end

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

      response "422", "unprocessable entity" do
        let(:shipment_request) { { foo: "bar" } }
        let(:commodity_infos) { {} }

        run_test!
      end
    end
  end
  # rubocop:enable Naming/VariableNumber
end
