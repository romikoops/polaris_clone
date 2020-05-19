# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "TruckingCounterparts" do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: "Gothenburg Port") }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
      country_code: "se")
  end
  let(:origin_trucking_location) {
    FactoryBot.create(:trucking_location, location: origin_location, country_code: "SE")
  }

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: origin_trucking_location)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
    Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
      "address_components" => [{"types" => ["premise"]}],
      "address" => "Göteborg, Sweden",
      "city" => "Gothenburg",
      "country" => "Sweden",
      "country_code" => "SE",
      "postal_code" => "43813"
    ])
  end

  path "/v1/trucking_counterparts" do
    get "Fetch counterparts fgor trucking" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :lat, in: :query, type: :string, schema: {type: :string}
      parameter name: :lng, in: :query, type: :string, schema: {type: :string}
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}
      parameter name: :tenant_id, in: :query, type: :string, schema: {type: :string}
      parameter name: :target, in: :query, type: :string, schema: {type: :string}

      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:load_type) { "cargo_item" }
      let(:tenant_id) { tenant.id }
      let(:target) { "origin" }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 countryCodes: {
                   type: :array,
                   items: {type: :string}
                 },
                 truckTypes: {
                   type: :array,
                   items: {type: :string}
                 },
                 truckingAvailable: {type: :boolean}
               },
               required: %w[countryCodes truckTypes truckingAvailable]

        run_test!
      end
    end
  end
end
