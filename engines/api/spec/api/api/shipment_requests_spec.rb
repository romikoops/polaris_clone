# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "ShipmentRequests", type: :request, swagger: true do
  let(:organization_id) { FactoryBot.create(:organizations_organization).id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization_id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let!(:company) { FactoryBot.create(:companies_company, organization_id: organization_id, name: "default") }

  before do
    Organizations.current_id = organization_id
  end

  path "/v2/organizations/{organization_id}/shipment_requests/{shipment_request_id}" do
    let(:shipment_request_id) { FactoryBot.create(:journey_shipment_request).id }

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

  path "/v2/organizations/{organization_id}/results/{result_id}/shipment_requests" do
    let(:result_id) do
      FactoryBot.create(:journey_result,
        query: FactoryBot.build(:journey_query,
          client: user,
          company: company,
          organization_id: organization_id)).id
    end
    post "Create a shipment request" do
      tags "ShipmentRequests"
      description "Create a shipment request"
      operationId "createShipmentRequest"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :result_id, in: :path, type: :string, description: "The ID of the Result you wish to create ShipmentRequest from"

      parameter name: :body_params, in: :body, schema: {
        type: :object,
        properties: {
          shipmentRequest: { "$ref" => "#/components/schemas/shipment_request_params" },
          commodityInfos: {
            type: :array,
            description: "Commodity infos",
            items: { "$ref" => "#/components/schemas/commodityInfo" }
          }
        }
      }

      let(:body_params) do
        {
          shipmentRequest: shipment_request,
          commodityInfos: commodity_infos
        }
      end

      response "201", "successful operation" do
        let(:shipment_request) do
          {
            commercialValueCents: 10,
            commercialValueCurrency: "eur",
            notes: "Some notes",
            preferredVoyage: "1234",
            withCustomsHandling: false,
            withInsurance: false,
            contactsAttributes: [{
              addressLine1: "1 street", addressLine2: "2 street", addressLine3: "3 street", city: "Hamburg",
              companyName: "Foo GmBH", countryCode: "de", email: "foo@bar.com", function: "notifyee", geocodedAddress: "GEOCODE_ADDRESS_12345",
              name: "John Smith", phone: "+49123456", point: "On point", postalCode: "PC12"
            }]
          }
        end

        let(:commodity_infos) do
          [
            { description: "Description 1", hsCode: "1504.90.60.00", imoClass: "1" },
            { description: "Description 2", hsCode: "2504.90.60.00", imoClass: "2" }
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
end
