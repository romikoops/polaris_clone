# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::TruckingAvailabilitiesController, type: :controller do
    routes { Engine.routes }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:user) { FactoryBot.create(:users_user, email: 'test@example.com', organization_id: organization.id) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:data) { JSON.parse(response.body) }
    let(:origin_location) do
      FactoryBot.create(:locations_location,
                        bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
                        country_code: 'se')
    end
    let(:destination_location) do
      FactoryBot.create(:locations_location,
                        bounds: FactoryBot.build(:legacy_bounds, lat: destination_hub.latitude, lng: destination_hub.longitude, delta: 0.4),
                        country_code: 'cn')
    end
    let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: 'SE') }
    let(:destination_trucking_location) { FactoryBot.create(:trucking_location, location: destination_location, country_code: 'CN') }
    let(:wrong_lat) { 10.00 }
    let(:wrong_lng) { 60.50 }

    before do
      FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
      FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
      FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: origin_hub, location: origin_trucking_location)
      FactoryBot.create(:trucking_trucking, organization_id: organization.id, hub: destination_hub, carriage: 'on', location: destination_trucking_location, truck_type: 'default2')
      Geocoder::Lookup::Test.add_stub([wrong_lat, wrong_lng], [
                                        'address_components' => [{ 'types' => ['premise'] }],
                                        'address' => 'Helsingborg, Sweden',
                                        'city' => 'Gothenburg',
                                        'country' => 'Sweden',
                                        'country_code' => 'SE',
                                        'postal_code' => '43822'
                                      ])
      Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
                                        'address_components' => [{ 'types' => ['premise'] }],
                                        'address' => 'Göteborg, Sweden',
                                        'city' => 'Gothenburg',
                                        'country' => 'Sweden',
                                        'country_code' => 'SE',
                                        'postal_code' => '43813'
                                      ])
      Geocoder::Lookup::Test.add_stub([destination_hub.latitude, destination_hub.longitude], [
                                        'address_components' => [{ 'types' => ['premise'] }],
                                        'address' => 'Shanghai, China',
                                        'city' => 'Shanghai',
                                        'country' => 'China',
                                        'country_code' => 'CN',
                                        'postal_code' => '210001'
                                      ])
      allow(controller).to receive(:current_organization).at_least(:once).and_return(organization)
    end

    describe 'GET #index' do
      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }

      context 'when trucking is available' do
        before do
          params = { lat: lat, lng: lng, load_type: 'cargo_item', organization_id: organization.id, target: 'origin' }
          request.headers['Authorization'] = token_header
          get :index, params: params, as: :json
        end

        it 'returns available trucking options' do
          aggregate_failures do
            expect(response).to be_successful
            expect(data['truckingAvailable']).to eq true
            expect(data['truckTypes']).to eq(['default'])
          end
        end
      end

      context 'when trucking is not available' do
        before do
          params = { lat: wrong_lat, lng: wrong_lng, load_type: 'container', organization_id: organization.id, target: 'destination' }
          request.headers['Authorization'] = token_header
          get :index, params: params, as: :json
        end

        it 'returns empty keys when no trucking is available' do
          aggregate_failures do
            expect(response).to be_successful
            expect(data['truckingAvailable']).to eq false
            expect(data['truckTypes']).to be_empty
          end
        end
      end
    end
  end
end
