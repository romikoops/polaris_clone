# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::EquipmentsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      FactoryBot.create(:users_membership, organization: organization, user: user)
      FactoryBot.create(:fcl_20_pricing, organization: organization, itinerary: itinerary)
      FactoryBot.create(:fcl_40_pricing, organization: organization, itinerary: itinerary)
      FactoryBot.create(:fcl_40_hq_pricing, organization: organization, itinerary: fcl_40_hq_itinerary)
      FactoryBot.create(:fcl_20_trucking, organization: organization, hub: shanghai, carriage: "pre",
                                          location: origin_trucking_location)
      FactoryBot.create(:fcl_pre_carriage_availability, hub: shanghai, query_type: :location)
      Geocoder::Lookup::Test.add_stub([shanghai.latitude, shanghai.longitude], [
        "address_components" => [{ "types" => ["premise"] }],
        "address" => "Shanghai, China",
        "city" => "Shanghai",
        "country" => "China",
        "country_code" => "CN",
        "postal_code" => "210001"
      ])
    end

    let(:access_token) { FactoryBot.create(:access_token, resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:user) { FactoryBot.create(:users_user) }

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:itinerary) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
    let!(:fcl_40_hq_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, organization: organization) }
    let(:gothenburg) { itinerary.destination_hub }
    let(:shanghai) { itinerary.origin_hub }
    let(:hamburg) { fcl_40_hq_itinerary.destination_hub }
    let(:origin_location) do
      FactoryBot.create(:locations_location,
        bounds: FactoryBot.build(:legacy_bounds, lat: shanghai.latitude, lng: shanghai.longitude, delta: 0.4),
        country_code: "de")
    end
    let(:origin_trucking_location) do
      FactoryBot.create(:trucking_location, query: :location, location: origin_location, country_code: "DE")
    end
    let(:origin_params) do
      { organization_id: organization.id, origin_latitude: shanghai.latitude, origin_longitude: shanghai.longitude }
    end
    let(:destination_params) do
      { organization_id: organization.id, destination_latitude: gothenburg.latitude, destination_longitude: gothenburg.longitude }
    end

    describe "GET #fcl" do
      it "Renders a json of equipments" do
        get :index, params: { organization_id: organization.id }

        expect(response_data).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
      end

      it "Renders a json of equipments related with origin" do
        get :index, params: origin_params.merge(origin_nexus_id: shanghai.nexus_id)

        expect(response_data).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
      end

      it "Renders a json of equipments related with origin lat/lngs" do
        get :index, params: origin_params

        expect(response_data).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
      end

      it "Renders a json of equipments related with origin (legacy format)" do
        get :index, params: { organization_id: organization.id, origin: shanghai.nexus_id }

        expect(response_data).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
      end

      it "Renders a json of equipments related with destination" do
        get :index, params: destination_params.merge(destination_nexus_id: gothenburg.nexus_id)

        expect(response_data).to match_array(%w[fcl_20 fcl_40])
      end

      it "Renders a json of equipments related with origin and destination" do
        get :index, params: {
          organization_id: organization.id, origin_nexus_id: shanghai.nexus_id, destination_nexus_id: hamburg.nexus_id
        }

        expect(response_data).to match_array(%w[fcl_40_hq])
      end
    end
  end
end
