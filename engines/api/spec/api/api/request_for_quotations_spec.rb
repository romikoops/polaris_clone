# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "RequestForQuotations", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:query) { FactoryBot.create(:journey_query, organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization)
  end

  path "/v2/organizations/{organization_id}/queries/{query_id}/request_for_quotations" do
    let(:organization_id) { organization.id }
    let(:query_id) { query.id }

    post "Create a Request" do
      tags "Quote"
      description "Creates a Journey::Request with the provided information"
      operationId "createRequest"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :query_id, in: :path, type: :string, description: "The current ID of the Journey::Query you wish to make a Request over."
      parameter name: :request_for_quotation_params, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, description: "Email of the client requesting for quotation." },
          fullName: { type: :string, description: "Name of the client requesting for quotation." },
          phone: { type: :string, description: "Phone number of the client requesting for quotation." }
        }
      }

      let(:request_for_quotation_params) do
        {
          fullName: "John Doe",
          email: "john.doe@example.com",
          phone: "+49-4647484950"
        }
      end

      response "201", "Successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     attributes: { "$ref" => "#/components/schemas/request_for_quotation" }
                   }
                 }
               },
               required: ["data"]

        run_test!
      end

      response "400", "Bad Request" do
        let(:request_for_quotation_params) { { email: "john.doe@example.com" } }

        run_test!
      end
    end
  end
end
