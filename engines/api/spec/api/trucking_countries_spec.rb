# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "TruckingCountries" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }

  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/trucking_countries" do
    get "Fetch enabled countries for tenant" do
      tags "Trucking"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :id, in: :query, type: :string, schema: {type: :string}, description: "Tenant ID"

      let(:id) { tenant.id }
      let!(:countries) { FactoryBot.create_list(:legacy_hub, 5, tenant: legacy_tenant) }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/country"}
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
