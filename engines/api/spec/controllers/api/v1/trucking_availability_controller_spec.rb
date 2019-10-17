# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::TruckingAvailabilityController, type: :controller do
    routes { Engine.routes }
    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.create(legacy: legacy_tenant) }
    let(:hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: legacy_tenant) }

    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }

    subject do
      request.headers['Authorization'] = token_header
      request_object
    end

    describe 'GET #index' do
      let(:lat) { 57.0 }
      let(:lng) { 11.0 }

      before do
        Geocoder::Lookup::Test.add_stub([lat, lng], [
                                          'address_components' => [{ 'types' => ['premise'] }],
                                          'address' => 'Göteborg, Sweden',
                                          'city' => 'Gothenburg',
                                          'country' => 'Sweden',
                                          'country_code' => 'SE',
                                          'postal_code' => '43813'
                                        ])
      end

      context 'when trucking is available' do
        let(:loc) { FactoryBot.create(:xl_swedish_location, admin_level: 6) }
        let(:tr_loc) { FactoryBot.create(:trucking_location, location: loc) }

        let(:request_object) do
          params = { 'lat' => lat, 'lng' => lng, 'load_type' => 'cargo_item', 'carriage' => 'pre', 'hub_ids' => hub.id.to_s, 'tenant_id' => legacy_tenant.id }
          get :index, params: params, as: :json
        end

        it 'should return available trucking options' do
          FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: hub, location: tr_loc)
          data = JSON.parse(subject.body)
          expect(response).to be_successful
          expect(data['truckingAvailable']).to eq true
          expect(data['hubIds']).to eq([hub.id])
        end
      end

      context 'when trucking is not available' do
        let(:request_object) do
          params = { 'lat' => lat, 'lng' => lng, 'load_type' => 'cargo_item', 'carriage' => 'pre', 'hub_ids' => hub.id.to_s, 'tenant_id' => legacy_tenant.id }
          get :index, params: params, as: :json
        end

        it 'returns empty keys when no trucking is available' do
          data = JSON.parse(subject.body)
          expect(response).to be_successful
          expect(data['truckingAvailable']).to eq false
          expect(data['hubIds']).to be_empty
        end
      end
    end
  end
end
