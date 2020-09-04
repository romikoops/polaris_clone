# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "TruckingAvailabilities" do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:organization_id) { organization.id }
  let(:user) { FactoryBot.create(:organizations_user, organization_id: organization.id) }
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

  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:Authorization) { "Bearer #{access_token.token}" }

  before do
    FactoryBot.create(:trucking_trucking, organization: organization, hub: origin_hub, location: origin_trucking_location)
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

  path "/v1/organizations/{organization_id}/trucking_availabilities" do
    get "Fetch Available Truckings" do
      tags "Quote"
      security [oauth: []]
      consumes "application/json"
      produces "application/json"

      parameter name: :organization_id, in: :path, type: :string, description: "The current organization ID"
      parameter name: :lat, in: :query, type: :string, schema: {type: :string}
      parameter name: :lng, in: :query, type: :string, schema: {type: :string}
      parameter name: :load_type, in: :query, type: :string, schema: {type: :string}
      parameter name: :organization_id, in: :query, type: :string, schema: {type: :string}
      parameter name: :client, in: :query, type: :string, schema: {type: :string}, description: "The client id of the query"
      parameter name: :target, in: :query, type: :string, schema: {type: :string}

      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:load_type) { "cargo_item" }
      let(:client) { user.id }
      let(:organization_id) { organization.id }
      let(:target) { "origin" }

      response "200", "successful operation" do
        schema type: :object,
               properties: {
                 truckTypes: {
                   type: :array,
                   items: {type: :string}
                 },
                 truckingAvailable: {type: :boolean}
               },
               required: %w[truckTypes truckingAvailable]

        run_test!
      end
    end
  end
end
