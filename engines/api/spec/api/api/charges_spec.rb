# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Charges", type: :request, swagger: true do
  include_context "journey_pdf_setup"

  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:users_membership, organization: organization, user: user)
    Treasury::ExchangeRate.create(from: "USD",
      to: "EUR", rate: 1.3,
      created_at: result.created_at - 30.seconds)
  end

  path "/v1/organizations/{organization_id}/quotations/{quotation_id}/charges/{id}" do
    let(:quotation_id) { query.id }
    let(:id) { result.id }

    get "Fetch tender charges" do
      tags "Quote"
      description "Fetches available tenders."
      operationId "getCharge"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Trip ID of the tender"
      parameter name: :quotation_id, in: :path, type: :string, description: "The selected quotation ID"

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: { "$ref" => "#/components/schemas/quotationTender" }
          },
          required: ["data"]

        run_test!
      end

      response "404", "Invalid Charge ID" do
        let(:id) { "deadbeef" }

        run_test!
      end
    end
  end

  path "/v2/organizations/{organization_id}/results/{result_id}/charges" do
    let(:result_id) { result.id }
    let(:currency) { "EUR" }

    get "Fetch Charges (Journey::LineItem)" do
      tags "Quote"
      description "Fetches the Line Items for the Result in question."
      operationId "getCharge"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :result_id, in: :path, type: :string, description: "The selected result ID"
      parameter name: :currency, in: :query, type: :string, description: "Optional currency to convert charges to"

      response "200", "successful operation" do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string, description: "The ID of the Charge" },
                  type: { type: :string },
                  attributes: { "$ref" => "#/components/schemas/v2Charge" }
                }
              }
            }
          },
          required: ["data"]

        run_test!
      end

      response "404", "Invalid Result ID" do
        let(:result_id) { "deadbeef" }

        run_test!
      end
    end
  end
end
