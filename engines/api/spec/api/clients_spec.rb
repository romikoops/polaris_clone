# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Clients" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: "imc-demo") }
  let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
  let(:role) { FactoryBot.create(:legacy_role, name: "shipper") }
  let(:clients) { FactoryBot.create_list(:legacy_user, 5, tenant: legacy_tenant, role: role) }

  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    clients.each do |client|
      FactoryBot.create(:profiles_profile, user_id: Tenants::User.find_by(legacy_id: client.id).id)
    end
  end

  path "/v1/clients" do
    get "Fetch all clients" do
      tags "Clients"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, schema: {type: :string}, description: "Search query"

      let(:q) { "" }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/user"}
                 }
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
            role: "shipper",
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

  path "/v1/clients/{id}" do
    get "Fetch specific client" do
      tags "Clients"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, schema: {type: :string}, description: "Client ID"

      let(:id) { Tenants::User.find_by(legacy_id: clients.sample.id).id }

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

  path "/v1/clients/{id}/password_reset" do
    patch "Password Reset" do
      tags "Clients"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :path, type: :string, schema: {type: :string}, description: "Client ID"

      let(:id) { Tenants::User.find_by(legacy_id: clients.sample.id).id }

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
