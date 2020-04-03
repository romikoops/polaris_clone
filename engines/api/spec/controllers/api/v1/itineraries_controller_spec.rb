# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ItinerariesController, type: :controller do
    routes { Engine.routes }

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { FactoryBot.create(:tenants_tenant, legacy: legacy_tenant, slug: 'demo-test') }

    describe 'GET #itineraries' do
      let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }
      let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
      let(:token_header) { "Bearer #{access_token.token}" }
      let(:itinerary_subject) do
        request.headers['Authorization'] = token_header
        request_object
      end

      let(:request_object) do
        get :index, as: :json
      end

      before do
        FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Ningbo - Gothenburg')
        FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Shanghai - Gothenburg')
        FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Qingdao - Gothenburg')
        FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Bangkok - Gothenburg')
        FactoryBot.create(:legacy_itinerary, :default, tenant: legacy_tenant, name: 'Tokyo - Gothenburg')
      end

      it 'has a successful respoonse' do
        expect(response).to be_successful
      end

      it 'returns a list of itineraries belonging to the tenant' do
        data = JSON.parse(itinerary_subject.body)
        expect(data['data'].length).to eq(5)
      end
    end

    describe 'GET #ports' do
      let(:itinerary_1) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant) }
      let(:itinerary_2) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: legacy_tenant) }
      let(:first_hub) { itinerary_1.stops.first.hub }
      let(:last_hub) { itinerary_1.stops.last.hub }

      let(:second_tenant) do
        legacy_tenant = FactoryBot.create(:legacy_tenant)
        Tenants::Tenant.find_by(legacy: legacy_tenant)
      end

      let(:itinerary_second_tenant) { FactoryBot.create(:shanghai_felixstowe_itinerary, tenant: second_tenant) }

      it 'returns a list of origin locations belonging to the tenant' do
        query = first_hub[:name]
        get :ports, as: :json, params: { tenant_uuid: tenant.id, location_type: 'origin', query: query }
        data = JSON.parse(response.body)['data']
        aggregate_failures do
          expect(response).to be_successful
          expect(data.first['attributes']['name']).to eq(query)
          expect(data.length).to eq(1)
        end
      end

      it 'returns filter related locations to origin' do
        query = last_hub[:name]
        get :ports, as: :json, params: { tenant_uuid: tenant.id, location_type: 'origin', location_id: first_hub[:id], query: query }
        data = JSON.parse(response.body)['data']

        aggregate_failures do
          expect(response).to be_successful
          expect(data.first['attributes']['name']).to eq(query)
          expect(data.length).to eq(1)
        end
      end

      it 'returns filter related locations to destination' do
        query = first_hub[:name]
        get :ports, as: :json, params: { tenant_uuid: tenant.id, location_type: 'destination', location_id: last_hub[:id], query: query }
        data = JSON.parse(response.body)['data']

        aggregate_failures do
          expect(response).to be_successful
          expect(data.first['attributes']['name']).to eq(query)
          expect(data.length).to eq(1)
        end
      end

      it 'filters locations by tenant' do
        get :ports, as: :json, params: { tenant_uuid: second_tenant.id, location_type: 'origin', query: first_hub[:name] }
        data = JSON.parse(response.body)['data']
        aggregate_failures do
          expect(response).to be_successful
          expect(data).to be_empty
        end
      end

      it 'returns empty if there are no locations for the tenant' do
        target = Tenants::Tenant.find_by(legacy: FactoryBot.create(:legacy_tenant))

        get :ports, as: :json, params: { tenant_uuid: target.id, location_type: 'origin', query: first_hub[:name] }

        data = JSON.parse(response.body)['data']
        expect(data.length).to eq(0)
      end

      it 'returns :not_found if tenant does not exist' do
        get :ports, as: :json, params: { tenant_uuid: 'tenant_uuid', location_type: 'origin', query: 'aaa' }

        expect(response).to have_http_status(:not_found)
      end

      it 'returns :bad_request if some of the params (:tenant_uuid and :location_type) are missing' do
        params = { tenant_uuid: tenant.id, location_type: 'origin', query: 'aaa' }

        get :ports, as: :json, params: params.except(:location_type)
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
