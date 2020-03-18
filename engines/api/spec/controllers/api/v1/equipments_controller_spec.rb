# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::EquipmentsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers['Authorization'] = token_header
      FactoryBot.create(:fcl_20_pricing, tenant: legacy_tenant, itinerary: itinerary)
      FactoryBot.create(:fcl_40_pricing, tenant: legacy_tenant, itinerary: itinerary)
      FactoryBot.create(:fcl_40_hq_pricing, tenant: legacy_tenant, itinerary: fcl_40_hq_itinerary)
    end

    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:user) { FactoryBot.create(:tenants_user, email: 'test@example.com', password: 'veryspeciallysecurehorseradish', tenant: tenant) }

    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { FactoryBot.create(:tenants_tenant, legacy: legacy_tenant) }
    let!(:itinerary) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: legacy_tenant) }
    let!(:fcl_40_hq_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: legacy_tenant) }
    let(:gothenburg) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
    let(:shanghai) { itinerary.hubs.find_by(name: 'Shanghai Port') }
    let(:hamburg) { fcl_40_hq_itinerary.hubs.find_by(name: 'Hamburg Port') }

    describe 'GET #fcl' do
      it 'Renders a json of equipments' do
        get :index

        expect(response_data).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
      end

      it 'Renders a json of equipments related with origin' do
        get :index, params: { origin: shanghai.nexus_id }

        expect(response_data).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
      end

      it 'Renders a json of equipments related with destination' do
        get :index, params: { destination: gothenburg.nexus_id }

        expect(response_data).to match_array(%w[fcl_20 fcl_40])
      end

      it 'Renders a json of equipments related with origin and destination' do
        get :index, params: { origin: shanghai.nexus_id, destination: hamburg.nexus_id }

        expect(response_data).to match_array(%w[fcl_40_hq])
      end
    end
  end
end
