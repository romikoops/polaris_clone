# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::QuotationsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers['Authorization'] = token_header
    end

    describe 'POST #create' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
      let(:tenants_user) { Tenants::User.find_by(legacy: user) }
      let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
      let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
      let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
      let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
      let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'quickly') }
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
      let(:trip_1) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tenant_vehicle) }
      let(:trip_2) { FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'container', tenant_vehicle: tenant_vehicle_2) }
      let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenants_user.id, scopes: 'public') }
      let(:token_header) { "Bearer #{access_token.token}" }
      let(:trips) { [trip_1, trip_2] }

      let(:params) do
        {
          quote: {
            selected_date: Time.zone.now,
            tenant_id: tenant.id,
            user_id: tenants_user.id,
            load_type: 'container',
            origin: { nexus_id: origin_hub.nexus_id },
            destination: { nexus_id: destination_hub.nexus_id }
          },
          shipment_info: { trucking_info: { pre_carriage: :pre } }
        }
      end

      context 'with available tenders' do
        before do
          [tenant_vehicle, tenant_vehicle_2].each do |t_vehicle|
            FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, tenant: tenant)
          end
          OfferCalculator::Schedule.from_trips(trips)
          FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, tenant: tenant)
          FactoryBot.create(:freight_margin, default_for: 'ocean', tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
        end

        context 'when client is provided' do
          it 'returns results successfully' do
            post :create, params: params

            expect(response).to be_successful
          end

          it 'returns 3 available tenders' do
            post :create, params: params

            expect(response_data.count).to eq 3
          end
        end

        context 'when no client is provided' do
          before do
            params[:quote][:user_id] = nil
          end

          it 'returns prices with default margins' do
            post :create, params: params

            expect(response_data.count).to eq 3
          end
        end
      end

      context 'when no available schedules' do
        it 'returns no available schedules error' do
          post :create, params: params

          expect(response_error).to eq 'There are no departures for this timeframe.'
        end
      end
    end
  end
end
