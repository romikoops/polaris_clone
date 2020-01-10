# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Calculator do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
  let!(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:gothenburg_address) { FactoryBot.create(:gothenburg_address) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:base_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'cargo_item',
                      destination_hub: nil,
                      origin_hub: nil,
                      desired_start_date: Date.today + 4.days,
                      user: user,
                      tenant: tenant)
  end
  let(:trip_1) do
    FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle)
  end
  let(:trip_2) do
    FactoryBot.create(:trip_with_layovers,
                      itinerary: itinerary,
                      load_type: 'cargo_item',
                      tenant_vehicle: tenant_vehicle,
                      start_date: 10.days.from_now,
                      end_date: 30.days.from_now)
  end
  let!(:schedules) do
    [
      OfferCalculator::Schedule.from_trip(trip_1),
      OfferCalculator::Schedule.from_trip(trip_2)
    ]
  end

  let(:cargo_item_attributes) do
    [
      {
        'payload_in_kg' => 120,
        'total_volume' => 0,
        'total_weight' => 0,
        'dimension_x' => 120,
        'dimension_y' => 80,
        'dimension_z' => 120,
        'quantity' => 1,
        'cargo_item_type_id' => pallet.id,
        'dangerous_goods' => false,
        'stackable' => true
      }
    ]
  end

  let(:aggregated_cargo_attributes) do
    {
      'volume' => 2.0,
      'weight' => 1000
    }
  end

  let(:container_attributes) do
    [
      {
        'payload_in_kg' => 12_000,
        'size_class' => 'fcl_20',
        'quantity' => 1,
        'dangerous_goods' => false
      },
      {
        'payload_in_kg' => 12_000,
        'size_class' => 'fcl_40',
        'quantity' => 1,
        'dangerous_goods' => false
      },
      {
        'payload_in_kg' => 12_000,
        'size_class' => 'fcl_40_hq',
        'quantity' => 1,
        'dangerous_goods' => false
      }
    ]
  end

  let(:params) do
    {
      shipment: {
        'id' => base_shipment.id,
        'direction' => 'export',
        'selected_day' => 4.days.from_now.beginning_of_day.to_s,
        'cargo_items_attributes' => [],
        'containers_attributes' => [],
        'trucking' => {
          'pre_carriage' => { 'truck_type' => '' },
          'on_carriage' => { 'truck_type' => '' }
        },
        'incoterm' => {},
        'aggregated_cargo_attributes' => nil
      }
    }
  end
  let!(:lcl_pricing) do
    FactoryBot.create(:legacy_lcl_pricing,
                      itinerary: itinerary,
                      tenant: tenant,
                      tenant_vehicle: tenant_vehicle)
  end

  before(:each) do
    stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host' => 'data.fixer.io',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json, headers: {})
  end

  context 'port to port' do
    let(:port_to_port_params) do
      params[:shipment]['origin'] = {
        'latitude' => origin_hub.latitude,
        'longitude' => origin_hub.longitude,
        'nexus_id' => origin_hub.nexus_id,
        'nexus_name' => origin_hub.nexus.name,
        'country' => origin_hub.nexus.country.code
      }
      params[:shipment]['destination'] = {
        'latitude' => destination_hub.latitude,
        'longitude' => destination_hub.longitude,
        'nexus_id' => destination_hub.nexus_id,
        'nexus_name' => destination_hub.nexus.name,
        'country' => destination_hub.nexus.country.code
      }
      params[:shipment]['cargo_items_attributes'] = cargo_item_attributes
      ActionController::Parameters.new(params)
    end
    let(:service) { described_class.new(shipment: base_shipment, params: port_to_port_params, user: user, sandbox: nil) }

    describe '.perform' do
      it 'perform a booking calulation' do
        results = service.perform
        expect(results.length).to eq(1)
        expect(results.first.keys).to match_array(%i(quote schedules meta notes))
        expect(results.first.dig(:quote, :total, :value)).to eq(28.8)
      end

      it 'perform a booking calulation' do
        port_to_port_params['shipment']['isQuote'] = true
        results = service.perform
        expect(results.length).to eq(1)
        expect(results.first.keys).to match_array(%i(quote schedules meta notes))
        expect(results.first.dig(:quote, :total, :value)).to eq(28.8)
      end
    end
  end
end
# update_incoterm
# update_cargo_units
# update_selected_day
# update_updated_at
