# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::TruckingCounterpartsController, type: :controller do
    routes { Engine.routes }
    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
    let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
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
    let!(:origin_hub_availability) { FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub) }
    let!(:destination_hub_availability) { FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, custom_truck_type: 'default2') }

    before do
      FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: origin_trucking_location)
      FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: destination_hub, carriage: 'on', location: destination_trucking_location)
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
      allow(controller).to receive(:current_user).at_least(:once).and_return(user)
      allow(controller).to receive(:current_tenant).at_least(:once).and_return(tenant)
    end

    describe 'GET #index' do
      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }

      context 'when destination trucking is available with lat lng args' do
        before do
          params = { lat: lat, lng: lng, load_type: 'cargo_item', tenant_id: legacy_tenant.id, target: 'origin' }
          request.headers['Authorization'] = token_header
          get :index, params: params, as: :json
        end

        it 'returns available trucking options and country codes' do
          aggregate_failures do
            expect(response).to be_successful
            expect(data['truckingAvailable']).to eq true
            expect(data['truckTypes']).to match_array([destination_hub_availability.truck_type])
            expect(data['countryCodes']).to eq(['cn'])
          end
        end
      end

      context 'when destination trucking is available with nexus_id args' do
        before do
          params = { id: origin_hub.nexus_id, load_type: 'cargo_item', tenant_id: legacy_tenant.id, target: :origin }
          request.headers['Authorization'] = token_header
          get :index, params: params, as: :json
        end

        it 'returns available trucking options and country codes' do
          aggregate_failures do
            expect(response).to be_successful
            expect(data['truckingAvailable']).to eq true
            expect(data['truckTypes']).to match_array([destination_hub_availability.truck_type])
            expect(data['countryCodes']).to eq(['cn'])
          end
        end
      end

      context 'when origin trucking is available with lat lng args' do
        let(:lat) { destination_hub.latitude }
        let(:lng) { destination_hub.longitude }

        before do
          params = { lat: lat, lng: lng, load_type: 'cargo_item', tenant_id: legacy_tenant.id, target: :destination }
          request.headers['Authorization'] = token_header
          get :index, params: params, as: :json
        end

        it 'returns available trucking options' do
          aggregate_failures do
            expect(response).to be_successful
            expect(data['truckingAvailable']).to eq true
            expect(data['truckTypes']).to eq([origin_hub_availability.truck_type])
            expect(data['countryCodes']).to eq(['se'])
          end
        end
      end

      context 'when origin trucking is available with nexus_id args' do
        before do
          params = { id: destination_hub.nexus_id, load_type: 'cargo_item', tenant_id: legacy_tenant.id, target: :destination }
          request.headers['Authorization'] = token_header
          get :index, params: params, as: :json
        end

        it 'returns available trucking options and country codes' do
          aggregate_failures do
            expect(response).to be_successful
            expect(data['truckingAvailable']).to eq true
            expect(data['truckTypes']).to eq([origin_hub_availability.truck_type])
            expect(data['countryCodes']).to eq(['se'])
          end
        end
      end
    end
  end
end
