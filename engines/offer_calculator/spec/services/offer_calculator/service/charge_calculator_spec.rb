# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Service::ChargeCalculator do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:cargo_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    FactoryBot.create(:legacy_transport_category, cargo_class: 'fcl_40_hq', load_type: 'container')
  end
  let(:vehicle) do
    FactoryBot.create(:legacy_vehicle,
                      transport_categories: [
                        fcl_20_transport_category,
                        fcl_40_transport_category,
                        fcl_40_hq_transport_category,
                        cargo_transport_category
                      ],
                      tenant_vehicles: [tenant_vehicle_1, tenant_vehicle_2])
  end
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: 'express') }
  let(:trip_1) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary_1, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_1)
  end
  let(:trip_2) do
    FactoryBot.create(:legacy_trip, itinerary: itinerary_2, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_2)
  end

  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant, tokens: {}) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '43813') }
  let(:hub) { itinerary_1.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary_1.hubs.find_by(name: 'Shanghai Port') }
  let!(:common_trucking) { FactoryBot.create(:trucking_trucking, tenant: tenant, hub: hub, location: trucking_location) }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:cargo_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: load_type,
                      direction: direction,
                      user: user,
                      has_pre_carriage: true,
                      tenant: tenant,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Date.today + 4.days,
                      cargo_items: [cargo_item])
  end
  let(:agg_cargo_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: load_type,
                      direction: direction,
                      user: user,
                      has_pre_carriage: true,
                      tenant: tenant,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'default',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Date.today + 4.days,
                      aggregated_cargo: FactoryBot.build(:legacy_aggregated_cargo))
  end
  let(:container_shipment) do
    FactoryBot.create(:legacy_shipment,
                      load_type: 'container',
                      direction: direction,
                      has_pre_carriage: true,
                      user: user,
                      trucking: {
                        'pre_carriage': {
                          'address_id': address.id,
                          'truck_type': 'chassis',
                          'trucking_time_in_seconds': 145_688
                        }
                      },
                      desired_start_date: Date.today + 4.days,
                      tenant: tenant,
                      containers: containers)
  end

  let(:itinerary_1) { FactoryBot.create(:legacy_itinerary, :gothenburg_shanghai, tenant: tenant) }
  let(:itinerary_2) { FactoryBot.create(:legacy_itinerary, :shanghai_gothenburg, tenant: tenant) }
  let(:cargo_item) { FactoryBot.create(:legacy_cargo_item) }
  let(:schedules) do
    [
      OfferCalculator::Schedule.from_trip(trip_1)
    ]
  end
  let(:containers) do
    [
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_20'),
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_40'),
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_40_hq')
    ]
  end

  let!(:default_margins) do
    %w(ocean air rail truck trucking local_charge).flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end

  let(:fcl_local_charge_fees) do
    { 'ADI' => { 'key' => 'ADI', 'max' => nil, 'min' => nil, 'name' => 'Admin Fee', 'value' => 27.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ECA' => { 'key' => 'ECA', 'max' => nil, 'min' => nil, 'name' => 'ECA/LSF', 'value' => 50, 'currency' => 'USD', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'FILL' =>
   { 'key' => 'FILL', 'max' => nil, 'min' => nil, 'name' => 'Filling Charges', 'value' => 35, 'currency' => 'EUR', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ISPS' => { 'key' => 'ISPS', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 25, 'currency' => 'EUR', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' } }
  end
  let(:lcl_local_charge_fees) do
    {
      'ADI' => { 'key' => 'ADI', 'max' => nil, 'min' => nil, 'name' => 'Admin Fee', 'value' => 27.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ECA' => { 'key' => 'ECA', 'max' => nil, 'min' => nil, 'name' => 'ECA/LSF', 'value' => 50, 'currency' => 'USD', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'FILL' => { 'key' => 'FILL', 'max' => nil, 'min' => nil, 'name' => 'Filling Charges', 'value' => 35, 'currency' => 'EUR', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ISPS' => { 'key' => 'ISPS', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 25, 'currency' => 'EUR', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'QDF' =>
          {
            'key' => 'QDF',
            'max' => nil,
            'min' => 57,
            'name' => 'Wharfage / Quay Dues',
            'range' => [{ 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' }, { 'cbm' => 8, 'max' => 40, 'min' => 6, 'currency' => 'EUR' }],
            'currency' => 'EUR',
            'rate_basis' => 'PER_UNIT_TON_CBM_RANGE'
          }
    }
  end
  let!(:lcl_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'lcl',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: lcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
  end
  let!(:lcl_destination_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: destination_hub,
                      mode_of_transport: 'ocean',
                      load_type: 'lcl',
                      direction: 'import',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: lcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
  end
  let!(:fcl_20_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_20',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: fcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
  end
  let!(:fcl_40_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_40',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: fcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
  end
  let!(:fcl_40_hq_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_40_hq',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: fcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
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
  let(:trucking_data) do
    {
      'pre' => {
        hub.id => {
          trucking_charge_data: {
            'lcl' => {
              'stackable' => {
                value: 0.10175e3,
                currency: 'USD'
              },
              'non_stackable' => {},
              total: {
                value: 0.10175e3,
                currency: 'USD'
              },
              'metadata_id' => '3b57c607-35de-433f-a29b-ea9c89e07ddd'
            }
          }
        }
      }
    }
  end
  let(:legacy_lcl_data) do
    {
      pricings_by_cargo_class: {
        'lcl' => {

        }
      }
    }
  end
  let!(:default_margins) do
    %w(ocean air rail truck trucking local_charge).flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end

  describe '.perform', :vcr do
    context 'legacy' do
      let!(:pricing_one) do
        FactoryBot.create(:legacy_lcl_pricing,
                          itinerary: itinerary_1,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: cargo_transport_category)
      end
      let!(:pricing_fcl_20) do
        FactoryBot.create(:legacy_fcl_20_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: fcl_20_transport_category)
      end
      let!(:pricing_fcl_40) do
        FactoryBot.create(:legacy_fcl_40_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: fcl_40_transport_category)
      end
      let!(:pricing_fcl_40_hq) do
        FactoryBot.create(:legacy_fcl_40_hq_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1,
                          transport_category: fcl_40_hq_transport_category)
      end
      let(:legacy_lcl_data) do
        {
          pricings_by_cargo_class: {
            'lcl' => pricing_one.as_json
          },
          schedules: schedules
        }
      end
      let(:legacy_fcl_data) do
        {
          pricings_by_cargo_class: {
            'fcl_20' => pricing_fcl_20.as_json,
            'fcl_40' => pricing_fcl_40.as_json,
            'fcl_40_hq' => pricing_fcl_40_hq.as_json
          },
          schedules: schedules
        }
      end

      it 'returns an object with calculated totals and schedules for lcl' do
        service = described_class.new(
          shipment: cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )

        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.43162e3)
      end

      it 'returns an object with calculated totals and schedules for lcl w/ mandatory charges' do
        mandatory_charge = FactoryBot.create(:legacy_mandatory_charge, import_charges: true)
        destination_hub.update(mandatory_charge_id: mandatory_charge.id)
        service = described_class.new(
          shipment: cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.77248e3)
      end

      it 'returns an object with calculated totals and schedules for aggregated cargo' do
        service = described_class.new(
          shipment: agg_cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.28994e3)
      end

      it 'returns an object with calculated totals and schedules for fcl cargo classes' do
        service = described_class.new(
          shipment: container_shipment,
          user: user,
          data: legacy_fcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.150698e4)
      end

      it 'returns an object with calculated totals and schedules for lcl w/ backend consolidation' do
        FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { consolidation: { cargo: { backend: true } } })
        service = described_class.new(
          shipment: cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.37462e3)
      end
    end
    context 'base pricing' do
      let!(:pricing_one) do
        FactoryBot.create(:lcl_pricing,
                          itinerary: itinerary_1,
                          tenant_vehicle: tenant_vehicle_1,
                          tenant: tenant)
      end
      let!(:pricing_fcl_20) do
        FactoryBot.create(:fcl_20_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1)
      end
      let!(:pricing_fcl_40) do
        FactoryBot.create(:fcl_40_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1)
      end
      let!(:pricing_fcl_40_hq) do
        FactoryBot.create(:fcl_40_hq_pricing,
                          itinerary: itinerary_1,
                          tenant: tenant,
                          tenant_vehicle: tenant_vehicle_1)
      end
      let(:legacy_lcl_data) do
        {
          pricings_by_cargo_class: {
            'lcl' => pricing_one.as_json
          },
          schedules: schedules
        }
      end
      let(:legacy_fcl_data) do
        {
          pricings_by_cargo_class: {
            'fcl_20' => pricing_fcl_20.as_json,
            'fcl_40' => pricing_fcl_40.as_json,
            'fcl_40_hq' => pricing_fcl_40_hq.as_json
          },
          schedules: schedules
        }
      end
      let(:trucking_metadata_list) do
        [
          {
            fees: {
              trucking_lcl: {
                breakdowns: [
                  {
                    adjusted_rate: {
                      'kg' => [
                        { 'rate' => { 'base' => 1.0, 'value' => 68.41, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '50.0', 'min_kg' => '0.0', 'min_value' => 0.0 },
                        { 'rate' => { 'base' => 1.0, 'value' => 70.81, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '80.0', 'min_kg' => '51.0', 'min_value' => 0.0 }
                      ]
                    }
                  },
                  {
                    margin_id: '5d13222b-fe4d-4393-962a-631b0504e618',
                    margin_value: 0.1e0,
                    operator: '%',
                    margin_target_type: 'Tenants::Group',
                    margin_target_id: 'ac561481-75a3-48e5-b200-480abb299285',
                    margin_target_name: 'Discounted',
                    adjusted_rate: {
                      'kg' =>
                      [{ 'rate' => { 'base' => 1.0, 'value' => 68.41, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '50.0', 'min_kg' => '0.0', 'min_value' => 0.0 },
                       { 'rate' => { 'base' => 1.0, 'value' => 70.81, 'currency' => 'USD', 'rate_basis' => 'PER_SHIPMENT' }, 'max_kg' => '80.0', 'min_kg' => '51.0', 'min_value' => 0.0 }]
                    }
                  }
                ]
              }
            }
          }
        ]
      end

      let!(:scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true }) }
      it 'returns an object with calculated totals and schedules for lcl' do
        service = described_class.new(
          shipment: cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.74498e3)
      end
      it 'returns an object with calculated totals and schedules for fcl cargo classes' do
        service = described_class.new(
          shipment: container_shipment,
          user: user,
          data: legacy_fcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.270317e4)
      end

      it 'returns an object with calculated totals and schedules for aggregated cargo' do
        service = described_class.new(
          shipment: agg_cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: []
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.28994e3)
      end
      it 'returns an object with two quotes with subtotals and grand totals w/ margins' do
        FactoryBot.create(:pricings_margin,
                          operator: '+',
                          value: 100,
                          itinerary_id: itinerary_1.id,
                          applicable: tenants_user,
                          tenant: tenants_tenant)
        FactoryBot.create(:export_margin,
                          origin_hub_id: hub.id,
                          applicable: tenants_user,
                          tenant: tenants_tenant)
        service = described_class.new(
          shipment: cargo_shipment,
          user: user,
          data: legacy_lcl_data,
          trucking_data: trucking_data,
          sandbox: nil,
          metadata_list: trucking_metadata_list
        )
        results = service.perform
        expect(results.count).to eq(1)
        expect(results.first.keys).to match_array(%i(total schedules metadata))
        expect(results.first[:metadata]).to be_a(Pricings::Metadatum)
        expect(results.first[:total].price.rounded_attributes).to eq(currency: 'EUR', value: 0.81041e3)
      end
    end
  end
end
