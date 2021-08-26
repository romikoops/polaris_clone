# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Companies", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:clients) { FactoryBot.create_list(:users_client, 5, organization: organization) }
  let(:group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let!(:companies_company) { FactoryBot.create(:companies_company, organization: organization, email: "foo@bar.com", name: "company1", phone: "112233", vat_number: "DE-VATNUMBER1") }
  let(:company_id) { companies_company.id }

  before do
    Organizations.current_id = organization_id
    FactoryBot.create(:companies_company, organization: organization, name: "default")
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200)
  end

  path "/v2/organizations/{organization_id}/companies/{company_id}" do
    get "Fetch a company" do
      tags "Companies"
      description "Fetch a specific company"
      operationId "getCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The current company id"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     attributes: { "$ref" => "#/components/schemas/company" }
                   }
                 }
               },
               required: ["data"]

        run_test!
      end

      response "404", "not found operation" do
        let(:company_id) { "non-existent-id" }

        run_test!
      end
    end

    put "Update a company" do
      tags "Companies"
      description "Update a specific company"
      operationId "updateCompany"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :company_id, in: :path, type: :string, description: "The current company id"
      parameter name: :query, in: :body, schema: {
        type: :object,
        properties: {
          company: {
            type: :object,
            properties: {
              email: { type: :string, description: "The email address of the company" },
              name: { type: :string, description: "The name of the company" },
              paymentTerms: { type: :string, description: "The payment terms, set out by the company" },
              phone: { type: :string, description: "The phone number of the company" },
              vatNumber: { type: :number, description: "The VAT number of the company" }
            }
          }
        }
      }

      response "200", "successful operation" do
        let(:query) do
          {
            company: {
              email: "awesome@company.com",
              name: "awesome company",
              paymentTerms: "an awesome payment term",
              phone: "112233",
              vatNumber: "VAT12345"
            }
          }
        end

        schema type: :object,
               properties: {
                 data: {
                   "$ref" => "#/components/schemas/company"
                 }
               },
               required: ["data"]

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:query) { { company: { foo: "bar" } } }

        run_test!
      end
    end
  end
end
