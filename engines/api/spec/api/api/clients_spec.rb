# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Clients", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_user) }
  let(:users_client) { FactoryBot.create(:users_client, organization: organization) }
  let(:clients) { FactoryBot.create_list(:users_client, 5, organization: organization) }
  let(:group) { FactoryBot.create(:groups_group, name: "default", organization: organization) }
  let(:company) { FactoryBot.create(:companies_company, name: "default", organization: organization) }
  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    Organizations.current_id = organization_id
    FactoryBot.create(:users_membership, organization: organization, user: user)
    FactoryBot.create(:companies_membership, client: users_client, company: company)
    clients.each do |client_x|
      FactoryBot.create(:companies_membership, client: client_x, company: company)
    end
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200)
  end

  path "/v1/organizations/{organization_id}/clients" do
    get "Fetch all clients" do
      tags "Clients"
      description "Fetch all customer client accounts."
      operationId "getClients"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :q, in: :query, type: :string, description: "Search query"
      parameter name: :page, in: :query, type: :number, description: "Page number"
      parameter name: :per_page, in: :query, type: :number, description: "Results per page"

      let(:q) { "" }
      let(:page) { 1 }
      let(:per_page) { 1 }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: { "$ref" => "#/components/schemas/v1Client" }
                 },
                 links: { "$ref" => "#/components/schemas/paginationLinks" }
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
      description "Creates a new client for the customer."
      operationId "createClient"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :query, in: :body, description: "Query", schema: { "$ref" => "#/components/schemas/client" },
                required: %w[email first_name last_name]

      let(:query) do
        {
          email: "john@example.com",
          first_name: "John",
          last_name: "Doe",
          company_name: "LumberJacks Ltd",
          phone: "+1 2345 2345",
          house_number: "1",
          street: "Address Unknown",
          postal_code: "12345",
          country: "Canada",
          group_id: group.id
        }
      end

      response "201", "successful operation" do
        run_test!
      end

      response "400", "invalid request" do
        let(:query) { {} }

        run_test!
      end

      response "401", "Invalid Credentials" do
        let(:Authorization) { "Basic deadbeef" }

        run_test!
      end
    end
  end

  path "/v1/organizations/{organization_id}/clients/{id}" do
    get "Fetch specific client" do
      tags "Clients"
      description "Fetch a given client."
      operationId "getClient"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Client ID"

      let(:id) { users_client.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: { "$ref" => "#/components/schemas/v1Client" }
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

  path "/v1/organizations/{organization_id}/clients/{id}" do
    delete "Destroy a specific client" do
      tags "Clients"
      description "Deletes an client."
      operationId "deleteClient"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Client ID"

      response "204", "successful operation" do
        let(:id) { users_client.id }

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
      description "Resets a client password."
      operationId "passwordReset"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Client ID"

      let(:id) { users_client.id }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     password: { type: :string }
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

  path "/v1/organizations/{organization_id}/clients/{id}" do
    patch "Update" do
      tags "Clients"
      description "Update client details."
      operationId "updateClient"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :id, in: :path, type: :string, description: "Client ID"

      parameter name: :client, in: :body, schema: {
        type: :object,
        properties: {
          client: { "$ref" => "#/components/schemas/client" }
        },
        required: %w[client]
      }

      let(:id) { users_client.id }

      response "204", "successful operation", skip: "flaky" do
        let(:client) do
          { client: {
            email: "john@example.com",
            first_name: "John",
            last_name: "Doe",
            company_name: "LumberJacks Ltd",
            phone: "+1 2345 2345"
          } }
        end

        run_test!
      end

      response "422", "Unprocessable Entity" do
        let(:client) do
          { client: {
            email: nil,
            first_name: "John",
            last_name: "Doe",
            company_name: "LumberJacks Ltd",
            phone: "+1 2345 2345"
          } }
        end

        run_test!
      end
    end
  end
end
