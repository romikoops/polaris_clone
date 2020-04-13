# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe V1::ValidationsController, type: :controller do
    routes { Engine.routes }
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
    let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}, with_profile: true) }
    let(:tenants_user) { Tenants::User.find_by(legacy: user) }
    let(:origin_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
    let(:destination_nexus) { FactoryBot.create(:legacy_nexus, tenant: tenant) }
    let(:origin_hub) { itinerary.origin_hub }
    let(:destination_hub) { itinerary.destination_hub }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
    let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'quickly') }
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenants_user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:shipping_info) { { trucking_info: { pre_carriage: :pre } } }
    let(:cargo_item_id) { SecureRandom.uuid }
    let(:params) do
      {
        quote: {
          tenant_id: tenant.id,
          user_id: tenants_user.id,
          load_type: 'container',
          origin: origin,
          destination: destination
        },
        shipment_info: shipping_info
      }
    end
    let(:cargo_items_attributes) do
      [
        {
          'id' => cargo_item_id,
          'payload_in_kg' => 120,
          'total_volume' => 0,
          'total_weight' => 0,
          'dimension_x' => 120,
          'dimension_y' => 80,
          'dimension_z' => 120,
          'quantity' => 1,
          'dangerous_goods' => false,
          'stackable' => true
        }
      ]
    end
    let(:origin) { { nexus_id: origin_hub.nexus_id } }
    let(:destination) { { nexus_id: destination_hub.nexus_id } }

    describe 'post #create' do
      context 'when port to port complete request (no pricings)' do
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            'id' => 'routing',
            'message' => 'No Pricings are available for your route',
            'attribute' => 'routing',
            'limit' => nil,
            'section' => 'routing',
            'code' => 4008
          }]
        end

        before do
          request.headers['Authorization'] = token_header
          post :create, params: params
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data.pluck('attributes')).to eq(expected_errors)
          end
        end
      end

      context 'when port to port complete request (no group pricings)' do
        let(:origin) { { nexus_id: origin_hub.nexus_id } }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            'id' => 'routing',
            'message' => 'No Pricings are available for your groups',
            'attribute' => 'routing',
            'limit' => nil,
            'section' => 'routing',
            'code' => 4009
          }]
        end

        before do
          FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { dedicated_pricings_only: true })
          request.headers['Authorization'] = token_header
          post :create, params: params
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data.pluck('attributes')).to eq(expected_errors)
          end
        end
      end

      context 'when port to port complete request (invalid cargo)' do
        let(:cargo_items_attributes) do
          [
            {
              'id' => cargo_item_id,
              'payload_in_kg' => 120,
              'total_volume' => 0,
              'total_weight' => 0,
              'dimension_x' => 120,
              'dimension_y' => 80,
              'dimension_z' => 1200,
              'quantity' => 1,
              'dangerous_goods' => false,
              'stackable' => true
            }
          ]
        end
        let(:origin) { { nexus_id: origin_hub.nexus_id } }
        let(:destination) { { nexus_id: destination_hub.nexus_id } }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [
            {
              'id' => cargo_item_id,
              'message' => 'Height exceeds the limit of 5 m',
              'limit' => '5 m',
              'attribute' => 'dimension_z',
              'section' => 'cargo_item',
              'code' => 4002
            },
            {
              'id' => cargo_item_id,
              'message' => 'Chargeable Weight exceeds the limit of 10000 kg',
              'limit' => '10000 kg',
              'attribute' => 'chargeable_weight',
              'section' => 'cargo_item',
              'code' => 4005
            }
          ]
        end

        before do
          FactoryBot.create(:lcl_pricing, tenant: tenant, itinerary: itinerary)
          request.headers['Authorization'] = token_header
          post :create, params: params
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data.pluck('attributes')).to eq(expected_errors)
          end
        end
      end

      context 'when port to port request (no routing &invalid cargo)' do
        let(:cargo_items_attributes) do
          [
            {
              'id' => cargo_item_id,
              'payload_in_kg' => 12_000,
              'total_volume' => 0,
              'total_weight' => 0,
              'dimension_x' => 120,
              'dimension_y' => 80,
              'dimension_z' => 100,
              'quantity' => 1,
              'dangerous_goods' => false,
              'stackable' => true
            }
          ]
        end
        let(:origin) { {} }
        let(:destination) { {} }
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [
            {
              'id' => cargo_item_id,
              'message' => 'Weight exceeds the limit of 10000 kg',
              'limit' => '10000 kg',
              'attribute' => 'payload_in_kg',
              'section' => 'cargo_item',
              'code' => 4001
            },
            {
              'id' => cargo_item_id,
              'message' => 'Chargeable Weight exceeds the limit of 10000 kg',
              'limit' => '10000 kg',
              'attribute' => 'chargeable_weight',
              'section' => 'cargo_item',
              'code' => 4005
            }
          ]
        end

        before do
          FactoryBot.create(:lcl_pricing, tenant: tenant, itinerary: itinerary)
          request.headers['Authorization'] = token_header
          post :create, params: params
        end

        it 'returns an array of one error' do
          aggregate_failures do
            expect(response).to be_successful
            expect(response_data.pluck('attributes')).to eq(expected_errors)
          end
        end
      end
    end
  end
end
