# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Quotations", type: :request, swagger: true do
  include_context "journey_pdf_setup"
  include_context "complete_route_with_trucking"
  let(:load_type) { "container" }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:cargo_classes) { ["fcl_20"] }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:source) { FactoryBot.create(:application) }
  let(:user) { FactoryBot.create(:users_user) }
  let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
  let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }

  before do
    allow(controller).to receive(:doorkeeper_application).and_return(FactoryBot.create(:application))
    allow(Carta::Client).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin)
    allow(Carta::Client).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination)
    ::Organizations.current_id = organization.id
    FactoryBot.create(:users_membership, organization: organization, user: user)
  end

  path "/v1/organizations/{organization_id}/quotations" do
    post "Create new quotation" do
      tags "Quote"
      description "Create new quotation"
      operationId "createQuotation"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :quote, in: :body, schema: {
        type: :object,
        properties: {
          quote: {
            type: :object,
            properties: {
              selected_date: { type: :string },
              user_id: { type: :string, nullable: true },
              origin: {
                type: :object,
                oneOf: [
                  { "$ref" => "#/components/schemas/locationV1Nexus" },
                  { "$ref" => "#/components/schemas/locationV1Trucking" }
                ]
              },
              destination: {
                type: :object,
                oneOf: [
                  { "$ref" => "#/components/schemas/locationV1Nexus" },
                  { "$ref" => "#/components/schemas/locationV1Trucking" }
                ]
              }
            }, required: %w[selected_date origin destination]
          },
          shipment_info: {
            type: :object,
            oneOf: [
              { "$ref" => "#/components/schemas/v1ShipmentInfoCargoItems" },
              { "$ref" => "#/components/schemas/v1ShipmentInfoContainers" }
            ]
          },
          async: { type: :boolean }
        }, required: %w[organization_id quote shipment_info]
      }

      response "200", "successful operation" do
        let(:quote) do
          {
            organization_id: organization.id,
            quote: {
              selected_date: Time.zone.now,
              user_id: user.id,
              load_type: "container",
              origin: { nexus_id: origin_hub.nexus_id },
              destination: { nexus_id: destination_hub.nexus_id },
              parent_id: nil
            },
            shipment_info: {
              trucking_info: {}
            }
          }
        end

        run_test!
      end
    end

    get "Fetch quotations" do
      tags "Quote"
      description "Fetch all Quotations"
      operationId "fetchQuotations"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :start_date,
                in: :query,
                type: :string,
                description: "The beginning of the date range for filtering Queries by their CargoReadyDate"
      parameter name: :end_date,
                in: :query,
                type: :string,
                description: "The end of the date range for filtering Queries by their CargoReadyDate"

      response "200", "successful operation" do
        let(:start_date) { Time.zone.now - 1.month }
        let(:end_date) { Time.zone.now }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/quotations/{id}" do
    get "Fetch existing quotation" do
      tags "Quote"
      description "Fetch existing quotation"
      operationId "getQuotation"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Quotation ID"
      parameter name: :organization_id, in: :query, type: :string, description: "The current organization ID"

      response "200", "successful operation" do
        let(:organization_id) { organization.id }
        let(:id) { query.id }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/quotations/{id}/download" do
    post "Download quotation as PDF" do
      tags "Quote"
      description "Download quotation as PDF"
      operationId "downloadQuotation"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Quotation ID"
      parameter name: :organization_id, in: :query, type: :string, description: "The current organization ID"
      parameter name: :format, type: :string, in: :query, description: "The desired download format (pdf/xlsx)"
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          tenders: {
            type: :array,
            items: {
              type: :string
            }
          }
        }, required: ["tenders"]
      }

      response "200", "successful operation" do
        let(:organization_id) { organization.id }
        let(:id) { query.id }
        let(:params) { { tenders: [result.id], format: format } }
        let(:format) { "pdf" }

        run_test!
      end
    end
  end
end
