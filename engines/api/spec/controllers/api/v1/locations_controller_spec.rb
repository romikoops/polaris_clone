# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::LocationsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers['Authorization'] = token_header
    end

    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { FactoryBot.create(:tenants_tenant, legacy: legacy_tenant) }
    let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:itinerary_2) { FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant) }
    let(:itinerary_3) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant) }
    let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
    let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
    let(:origin_nexus) { origin_hub.nexus }
    let(:destination_nexus) { destination_hub.nexus }

    describe 'GET #origins' do
      it 'Renders a json of origins for given a destination id' do
        FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant)
        FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant)

        get :origins, params: { id: destination_hub.nexus_id }

        origins = %w[Gothenburg Felixstowe Hamburg]
        expect(response_data.map { |origin| origin.dig('attributes', 'name') }).to eq(origins)
      end

      it 'Renders a json of origins when query matches origin' do
        get :origins, params: { q: 'Goth' }
        expect(response_data[0]['attributes']['name']).to eq(origin_nexus.name)
      end

      it 'Renders an array of all origins when location params are empty' do
        get :origins, params: {}
        expect(response_data[0]['attributes']['name']).to eq(origin_nexus.name)
      end
    end

    describe 'GET #destinations' do
      it 'Renders a json of destinations for a given a origin id' do
        get :destinations, params: { id: origin_hub.nexus_id }

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end

      it 'Renders a json of destinations when query matches destination name' do
        get :destinations, params: { q: 'Shan' }

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end

      it 'Renders an array of all destinations when location params are empty' do
        get :destinations, params: {}

        expect(response_data[0]['attributes']['name']).to eq(destination_nexus.name)
      end
    end
  end
end
