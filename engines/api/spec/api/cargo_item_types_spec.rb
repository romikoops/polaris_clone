# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Cargo Items" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant, slug: "1234") }
  let(:tenant_group) { Tenants::Group.create(tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }
  let(:user) do
    FactoryBot.create(
      :tenants_user, email: "test@example.com", password: "veryspeciallysecurehorseradish", tenant: tenant
    )
  end

  before do
    FactoryBot.create(:legacy_tenant_cargo_item_type, tenant: legacy_tenant)
  end

  path "/v1/cargo_item_types" do
    get "Fetch all available cargo types" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/cargo_item_type"}
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
  end
end
