# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "TruckingCounterparts", type: :request, swagger: true do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:users_client, organization_id: organization.id) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:origin_hub) { itinerary.origin_hub }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
      bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
      country_code: "se")
  end
  let(:origin_trucking_location) {
    FactoryBot.create(:trucking_location, location: origin_location, country_code: "SE")
  }

  let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(
      :trucking_trucking, organization: organization, hub: origin_hub, location: origin_trucking_location
    )
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

  path "/v1/organizations/{organization_id}/trucking_counterparts" do
    get "Fetch counterparts fgor trucking" do
      tags "Quote"
      description "Fetch counterparts fgor trucking"
      operationId "getTruckingCounterparts"

      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :lat, in: :query, type: :string, description: "Latitude"
      parameter name: :lng, in: :query, type: :string, description: "Longitude"
      parameter name: :load_type, in: :query, type: :string, description: "Load type"
      parameter name: :organization_id, in: :query, type: :string, description: "Organization ID"
      parameter name: :client, in: :query, type: :string, description: "The client id of the query"
      parameter name: :target, in: :query, type: :string, description: "Target"

      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:client) { user.id }
      let(:load_type) { "cargo_item" }
      let(:organization_id) { organization.id }
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
