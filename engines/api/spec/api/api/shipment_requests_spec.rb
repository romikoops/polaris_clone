# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "ShipmentRequests", type: :request, swagger: true do
  include ActionDispatch::TestProcess
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization_id) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let!(:company) { FactoryBot.create(:companies_company, organization_id: organization_id, name: "default") }

  path "/v2/organizations/{organization_id}/shipment_requests" do
    get "Fetch all shipment requests for a client" do
      tags "ShipmentRequests"
      description "Fetch all shipment requests"
      operationId "getShipmentRequests"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :sortBy,
        in: :query,
        type: :string,
        description: "The attribute by which to sort the Shipment Requests",
        enum: %w[
          created_at
          origin
          destination
        ]
      parameter name: :direction,
        in: :query,
        type: :string,
        description: "The defining whether the sorting is ascending or descending",
        enum: %w[
          asc
          desc
        ]
      parameter name: :page,
        in: :query,
        type: :string,
        description: "The page of Shipment Requests requested"
      parameter name: :perPage,
        in: :query,
        type: :string,
        description: "The number of Shipment Requests requested per page"

      parameter name: :searchBy,
        in: :query,
        type: :string,
        description: "The attribute of the shipment requests and its related models to search through",
        enum: %w[origin_search destination_search status_search reference_search]

      parameter name: :searchQuery,
        in: :query,
        type: :string,
        description: "The value we want to use in our search"

      let(:sortBy) { "created_at" }
      let(:direction) { "asc" }
      let(:page) { 1 }
      let(:perPage) { 10 }
      let(:searchBy) { "origin" }
      let(:searchQuery) { "Hamburg" }

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { "$ref" => "#/components/schemas/shipment_request_index" }
            }
          },
          required: ["data"]

        run_test!
      end
    end
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

    before do
      Organizations.current_id = organization_id
      FactoryBot.create(:journey_shipment_request, client: user, result: FactoryBot.create(:journey_result, query: FactoryBot.build(:journey_query, client: user, organization_id: organization_id)))
      allow(Pdf::Shipment::Request).to receive(:new).and_return(instance_double("Pdf::Shipment::Request", file: true))
      allow(ActionDispatch::Http::UploadedFile).to receive(:new).and_return(uploaded_document)
    end

    post "Create a shipment request" do
      tags "ShipmentRequests"
      description "Create a shipment request"
      operationId "createShipmentRequest"

      security [oauth: []]
      consumes "multipart/form-data"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :result_id, in: :path, type: :string, description: "The ID of the Result you wish to create ShipmentRequest from"

      parameter name: :shipmentRequest, in: :formData, schema: { "$ref" => "#/components/schemas/shipment_request_params" }
      parameter name: :commodityInfos, in: :formData, schema: {
        type: :array,
        description: "Commodity infos",
        items: { "$ref" => "#/components/schemas/commodityInfo" }
      }

      let(:shipmentRequest) do
        {
          commercialValueCents: 10,
          commercialValueCurrency: "eur",
          notes: "Some notes",
          preferredVoyage: "1234",
          withCustomsHandling: false,
          withInsurance: false,
          documents: [uploaded_document],
          contactsAttributes: [{
            addressLine1: "1 street", addressLine2: "2 street", addressLine3: "3 street", city: "Hamburg",
            companyName: "Foo GmBH", countryCode: "de", email: "foo@bar.com", function: "notifyee", geocodedAddress: "GEOCODE_ADDRESS_12345",
            name: "John Smith", phone: "+49123456", point: "On point", postalCode: "PC12"
          }]
        }
      end

      let(:commodityInfos) do
        [
          { description: "Description 1", hsCode: "1504.90.60.00", imoClass: "1" },
          { description: "Description 2", hsCode: "2504.90.60.00", imoClass: "2" }
        ]
      end
      let(:uploaded_document) { fixture_file_upload("spec/fixtures/files/dummy.xlsx") }

      response "201", "successful operation" do
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

      response "422", "invalid file type" do
        let(:uploaded_document) { fixture_file_upload("spec/fixtures/files/dummy.json", "application/json") }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/admin/companies/{company_id}/shipment_requests" do
    get "Fetch all shipment requests for a client" do
      tags "ShipmentRequests"
      description "Fetch all shipment requests"
      operationId "getShipmentRequests"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The company ID for which the shipments have to be retrieved"
      parameter name: :sortBy,
        in: :query,
        type: :string,
        description: "The attribute by which to sort the Shipment Requests",
        enum: %w[
          created_at
          origin
          destination
        ]
      parameter name: :direction,
        in: :query,
        type: :string,
        description: "The defining whether the sorting is ascending or descending",
        enum: %w[
          asc
          desc
        ]
      parameter name: :page,
        in: :query,
        type: :string,
        description: "The page of Shipment Requests requested"
      parameter name: :perPage,
        in: :query,
        type: :string,
        description: "The number of Shipment Requests requested per page"

      parameter name: :searchBy,
        in: :query,
        type: :string,
        description: "The attribute of the shipment requests and its related models to search through",
        enum: %w[origin_search destination_search status_search reference_search]

      parameter name: :searchQuery,
        in: :query,
        type: :string,
        description: "The value we want to use in our search"

      let(:sortBy) { "created_at" }
      let(:direction) { "asc" }
      let(:page) { 1 }
      let(:perPage) { 10 }
      let(:searchBy) { "origin" }
      let(:searchQuery) { "Hamburg" }
      let(:user) { FactoryBot.create(:users_user).tap { |user| FactoryBot.create(:users_membership, organization: organization, user: user) } }
      let(:company_id) { company.id }

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { "$ref" => "#/components/schemas/shipment_request_admin_index" }
            }
          },
          required: ["data"]

        run_test!
      end
    end
  end
end
