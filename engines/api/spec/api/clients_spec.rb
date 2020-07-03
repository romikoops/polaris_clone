# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Clients" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user_with_profile, organization_id: organization.id) }
  let(:clients) { FactoryBot.create_list(:organizations_user_with_profile, 5, organization: organization) }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    Organizations.current_id = organization_id
  end

  path "/v1/organizations/{organization_id}/clients" do
    get "Fetch all clients" do
      tags "Clients"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :q, in: :query, type: :string, schema: {type: :string}, description: "Search query"
      parameter name: :page, in: :query, type: :number, schema: {type: :number}, description: "Page number"
      parameter name: :per_page, in: :query, type: :number, schema: {type: :number}, description: "Results per page"

      let(:q) { "" }
      let(:page) { 1 }
      let(:per_page) { 1 }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/user"}
                 },
                 meta: {
                   pagination: {"$ref" => "#/components/schemas/pagination"}
                 },
                 links: {"$ref" => "#/components/schemas/paginationLinks"}
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end

    post "Create a new client" do
      tags "Clients"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :client, in: :body, schema: {
        type: :object,
        properties: {
          client: {"$ref" => "#/components/schemas/client"}
        },
        required: %w[client]
      }

      response "201", "successful operation" do
        let(:client) do
          {client: {
            email: "john@example.com",
            first_name: "John",
            last_name: "Doe",
            company_name: "LumberJacks Ltd",
            phone: "+1 2345 2345",
            house_number: "1",
            street: "Address Unknown",
            postal_code: "12345",
            country: "Canada",
            group_id: "1"
          }}
        end

        run_test!
      end

      response "400", "invalid request" do
        let(:client) do
          {client: {}}
        end

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }
        let(:client) { {} }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/clients/{id}" do
    get "Fetch specific client" do
      tags "Clients"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, schema: {type: :string}, description: "Client ID"

      let(:id) { clients.sample.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {"$ref" => "#/components/schemas/user"}
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end

      response "404", "Invalid Client ID" do
        let(:id) { "deadbeef" }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/clients/{id}/password_reset" do
    patch "Password Reset" do
      tags "Clients"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, schema: {type: :string}, description: "Client ID"

      let(:id) { clients.sample.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     password: {type: :string}
                   },
                   required: ["password"]
                 }
               },
               required: ["data"]

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end

      response "404", "Invalid Client ID" do
        let(:id) { "deadbeef" }

        run_test!
      end
    end
  end
end
