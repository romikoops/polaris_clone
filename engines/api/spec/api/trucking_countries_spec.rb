# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "TruckingCountries" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:location) { FactoryBot.create(:zipcode_location, zipcode: "00001", country_code: "SE") }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: location)
  end

  path "/v1/trucking_countries" do
    get "Fetch enabled countries for tenant" do
      tags "Trucking"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :tenant_id, in: :query, type: :string, schema: {type: :string}, description: "Tenant ID"
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}, description: "Load Type"
      parameter name: :location_type, in: :query, type: :string, schema: {type: :string}, description: "Location Type"

      let(:tenant_id) { tenant.id }
      let(:load_type) { "cargo_item" }
      let(:location_type) { "destination" }

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
