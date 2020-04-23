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
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: tenants_user.id, scopes: 'public') }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:gothenburg_address) { FactoryBot.create(:gothenburg_address) }
    let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
    let(:shipping_info) { { trucking_info: { pre_carriage: :pre } } }
    let(:origin_location) do
      FactoryBot.create(:locations_location,
                        bounds: FactoryBot.build(:legacy_bounds, lat: gothenburg_address.latitude, lng: gothenburg_address.longitude, delta: 0.4),
                        country_code: gothenburg_address.country.code.downcase)
    end
    let(:destination_location) do
      FactoryBot.create(:locations_location,
                        bounds: FactoryBot.build(:legacy_bounds, lat: shanghai_address.latitude, lng: shanghai_address.longitude, delta: 0.4),
                        country_code: shanghai_address.country.code.downcase)
    end
    let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: gothenburg_address.country.code.upcase) }
    let(:destination_trucking_location) { FactoryBot.create(:trucking_location, location: destination_location, country_code: shanghai_address.country.code.upcase) }
    let(:pre_carriage_type_availability) { FactoryBot.create(:trucking_type_availability, truck_type: 'default', carriage: 'pre', query_method: :location) }
    let(:on_carriage_type_availability) { FactoryBot.create(:trucking_type_availability, truck_type: 'default', carriage: 'on', query_method: :location) }
    let(:params) do
      {
        quote: {
          tenant_id: tenant.id,
          user_id: tenants_user.id,
          load_type: 'cargo_item',
          origin: origin,
          destination: destination
        },
        shipment_info: shipping_info
      }
    end
    let(:cargo_items_attributes) do
      [
        {
          'id' => SecureRandom.uuid,
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
    let(:origin) { { latitude: gothenburg_address.latitude, longitude: gothenburg_address.longitude } }
    let(:destination) { { latitude: shanghai_address.latitude, longitude: shanghai_address.longitude } }
    let(:cargo_item_id) { SecureRandom.uuid }

    before do
      FactoryBot.create(:trucking_hub_availability, hub: origin_hub, type_availability: pre_carriage_type_availability)
      FactoryBot.create(:trucking_hub_availability, hub: destination_hub, type_availability: on_carriage_type_availability)
      FactoryBot.create(:trucking_trucking, tenant: tenant, hub: origin_hub, location: origin_trucking_location)
      FactoryBot.create(:trucking_trucking, tenant: tenant, hub: destination_hub, carriage: 'on', location: destination_trucking_location)
      Geocoder::Lookup::Test.add_stub([gothenburg_address.latitude, gothenburg_address.longitude], [
                                        'address_components' => [{ 'types' => ['premise'] }],
                                        'address' => gothenburg_address.geocoded_address,
                                        'city' => gothenburg_address.city,
                                        'country' => gothenburg_address.country.name,
                                        'country_code' => gothenburg_address.country.code,
                                        'postal_code' => gothenburg_address.zip_code
                                      ])
      Geocoder::Lookup::Test.add_stub([shanghai_address.latitude, shanghai_address.longitude], [
                                        'address_components' => [{ 'types' => ['premise'] }],
                                        'address' => shanghai_address.geocoded_address,
                                        'city' => shanghai_address.city,
                                        'country' => shanghai_address.country.name,
                                        'country_code' => shanghai_address.country.code,
                                        'postal_code' => shanghai_address.zip_code
                                      ])
    end

    describe 'post #create' do
      context 'when door to door complete request (no pricings)' do
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            'id' => 'routing',
            'limit' => nil,
            'message' => 'No Pricings are available for your route',
            'attribute' => 'routing',
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

      context 'when door to door complete request (no group pricings)' do
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [{
            'id' => 'routing',
            'limit' => nil,
            'message' => 'No Pricings are available for your groups',
            'attribute' => 'routing',
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

      context 'when door to door complete request (invalid cargo)' do
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
              'limit' => '10000 kg',
              'message' => 'Chargeable Weight exceeds the limit of 10000 kg',
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

      context 'when door to door complete request (invalid cargo  & multiple mots)' do
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
        let(:shipping_info) { { cargo_items_attributes: cargo_items_attributes } }
        let(:expected_errors) do
          [
            {
              'id' => cargo_item_id,
              'limit' => '5 m',
              'message' => 'Height exceeds the limit of 5 m',
              'attribute' => 'dimension_z',
              'section' => 'cargo_item',
              'code' => 4002
            },
            {
              'attribute' => 'chargeable_weight',
              'code' => 4005,
              'id' => cargo_item_id,
              'limit' => '10000 kg',
              'message' => 'Chargeable Weight exceeds the limit of 10000 kg',
              'section' => 'cargo_item'
            }
          ]
        end
        let(:air_itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: 'air', tenant: tenant) }
        let(:origin_airport) { air_itinerary.origin_hub }
        let(:destination_airport) { air_itinerary.destination_hub }

        before do
          FactoryBot.create(:trucking_hub_availability, hub: origin_airport, type_availability: pre_carriage_type_availability)
          FactoryBot.create(:trucking_hub_availability, hub: destination_airport, type_availability: on_carriage_type_availability)
          FactoryBot.create(:trucking_trucking, tenant: tenant, hub: origin_airport, location: origin_trucking_location)
          FactoryBot.create(:trucking_trucking, tenant: tenant, hub: destination_airport, carriage: 'on', location: destination_trucking_location)
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
