# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Locations" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: "Gothenburg Port") }
  let(:destination_hub) { itinerary.hubs.find_by(name: "Shanghai Port") }
  let(:address) { FactoryBot.build(:gothenburg_address) }
  let(:load_type) { "cargo_item" }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  path "/v1/locations/origins" do
    get "Fetch available origins" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, schema: {type: :string}
      parameter name: :id, in: :query, type: :string, schema: {type: :string}
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}

      let(:id) { destination_hub.nexus_id }
      let(:q) { nil }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/nexus"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end

  path "/v1/locations/destinations" do
    get "Fetch available destinations" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :q, in: :query, type: :string, schema: {type: :string}
      parameter name: :id, in: :query, type: :string, schema: {type: :string}
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}

      let(:id) { origin_hub.nexus_id }
      let(:q) { nil }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {"$ref" => "#/components/schemas/nexus"}
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end
