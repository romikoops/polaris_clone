# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::LocationsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers['Authorization'] = token_header
      ::Organizations.current_id = organization.id
    end

    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:user) { FactoryBot.create(:organizations_user, email: 'test@example.com', organization_id: organization.id) }

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:origin_nexus) { origin_hub.nexus }
    let(:destination_nexus) { destination_hub.nexus }
    let(:load_type) { 'cargo_item' }

    describe 'GET #origins' do
      it 'Renders a json of origins for given a destination id' do
        FactoryBot.create(:felixstowe_shanghai_itinerary, organization_id: organization.id)
        FactoryBot.create(:hamburg_shanghai_itinerary, organization_id: organization.id)

        get :origins, params: { organization_id: organization.id, id: destination_hub.nexus_id, load_type: load_type }

        origins = Legacy::Itinerary.where(organization: organization).map { |itin| itin.first_nexus.name }
        expect(response_data.map { |origin| origin.dig('attributes', 'name') }).to match_array(origins)
      end

      it 'Renders a json of origins when query matches origin' do
        get :origins, params: { organization_id: organization.id, q: 'Goth', load_type: load_type }

        expect(response_data[0]['attributes']['name']).to eq(origin_nexus.name)
      end

      it 'Renders an array of all origins when location params are empty' do
        get :origins, params: { organization_id: organization.id }
        expect(response_data[0]['attributes']['name']).to eq(origin_nexus.name)
      end
    end

    describe 'GET #destinations' do
      let(:origin_location) do
        FactoryBot.create(:locations_location,
          bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
          country_code: 'se')
      end
      let(:origin_trucking_location) {
        FactoryBot.create(:trucking_location, location: origin_location, country_code: 'SE')
      }

      before do
        Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
          'address_components' => [{ 'types' => ['premise'] }],
          'address' => 'Göteborg, Sweden',
          'city' => 'Gothenburg',
          'country' => 'Sweden',
          'country_code' => 'SE',
          'postal_code' => '43813'
        ])
        FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
        FactoryBot.create(:trucking_trucking,
          organization: organization,
          hub: origin_hub,
          location: origin_trucking_location)
      end

      it 'Renders a json of destinations for a given a origin id' do
        get :destinations, params: { organization_id: organization.id, id: origin_hub.nexus_id, load_type: load_type }

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end

      it 'Renders a json of destinations for a given coordinates' do
        get :destinations, params: { organization_id: organization.id, lat: origin_hub.latitude, lng: origin_hub.longitude, load_type: load_type }

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end

      it 'Renders a json of destinations when query matches destination name' do
        get :destinations, params: { organization_id: organization.id, q: 'Shan', load_type: load_type }

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end

      it 'Renders an array of all destinations when location params are empty' do
        get :destinations, params: { organization_id: organization.id }

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end
    end
  end
end
