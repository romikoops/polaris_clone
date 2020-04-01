# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::PricingTools do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:tenants_scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant) }
  let(:cargo_transport_category) do
    FactoryBot.create(:transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    FactoryBot.create(:transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    FactoryBot.create(:transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    FactoryBot.create(:transport_category, cargo_class: 'fcl_40_hq', load_type: 'container')
  end
  let(:vehicle) do
    FactoryBot.create(:vehicle,
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
  let(:fcl_trips) do
    [
      FactoryBot.create(:legacy_trip, load_type: 'container', tenant_vehicle: tenant_vehicle_1),
      FactoryBot.create(:legacy_trip, load_type: 'container', tenant_vehicle: tenant_vehicle_2)
    ]
  end
  let(:lcl_trips) do
    [
      FactoryBot.create(:legacy_trip, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_1),
      FactoryBot.create(:legacy_trip, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_2)
    ]
  end
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:all_trips) { lcl_trips | fcl_trips }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:group) { FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST') }
  let(:membership) { FactoryBot.create(:tenants_membership, group: group, member: tenants_user) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: load_type, direction: direction, user: user, tenant: tenant, origin_nexus: origin_nexus, destination_nexus: destination_nexus, trip: itinerary.trips.first, itinerary: itinerary) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, hubs: [origin_hub]) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, hubs: [destination_hub]) }
  let!(:itinerary) { FactoryBot.create(:legacy_itinerary, tenant: tenant, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: fcl_trips | lcl_trips) }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:origin_stop) { FactoryBot.create(:legacy_stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { FactoryBot.create(:legacy_stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { FactoryBot.create(:legacy_layover, stop_index: 0, trip: fcl_trips.first) }
  let(:destination_layover) { FactoryBot.create(:legacy_layover, stop_index: 1, trip: fcl_trips.first) }
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
  let!(:local_charge_margin) { FactoryBot.create(:export_margin, tenant: tenants_tenant, origin_hub: origin_hub) }
  let!(:lcl_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: origin_hub,
                      mode_of_transport: 'ocean',
                      load_type: 'lcl',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: lcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
  end
  let!(:group_lcl_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: origin_hub,
                      mode_of_transport: 'ocean',
                      load_type: 'lcl',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: lcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months,
                      group_id: group.id)
  end
  let!(:fcl_20_local_charge) do
    FactoryBot.create(:legacy_local_charge,
                      tenant: tenant,
                      hub: origin_hub,
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
                      hub: origin_hub,
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
                      hub: origin_hub,
                      mode_of_transport: 'ocean',
                      load_type: 'fcl_40_hq',
                      direction: 'export',
                      tenant_vehicle: tenant_vehicle_1,
                      fees: fcl_local_charge_fees,
                      effective_date: Date.today,
                      expiration_date: Date.today + 3.months)
  end
  let(:cargo_object) do
    {
      'stackable' => {
        'volume' => 0,
        'weight' => 0,
        'number_of_items' => 0
      }, 'non_stackable' => {
        'volume' => 0,
        'weight' => 0,
        'number_of_items' => 0
      }
    }
  end
  let(:fcl_schedules) do
    fcl_trips.map do |trip|
      OfferCalculator::Schedule.from_trip(trip)
    end
  end
  let(:lcl_schedules) do
    lcl_trips.map do |trip|
      OfferCalculator::Schedule.from_trip(trip)
    end
  end
  let!(:default_margins) do
    %w[ocean air rail truck trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end
  before do
    FactoryBot.create(:profiles_profile, user_id: tenants_user.id)
    stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
      .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json, headers: {})
    %w[adi eca qdf fill isps].each do |code|
      FactoryBot.create(:legacy_charge_categories, code: code, name: code, tenant: tenant)
    end
  end

  let(:fcl_20) { FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_20', cargo_class: 'fcl_20') }
  let(:fcl_40) { FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_40', cargo_class: 'fcl_40') }
  let(:fcl_40_hq) { FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_40_hq', cargo_class: 'fcl_40_hq') }

  describe '.find_local_charges' do
    it 'returns the correct number of charges for multiple cargo classes (FCL)' do
      cargos = [fcl_20, fcl_40, fcl_40_hq]
      local_charges_data, metadata = described_class.new(user: user, shipment: shipment).find_local_charge(fcl_schedules, cargos, 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.first.first.length).to eq(3)
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING)' do
      FactoryBot.create(:tenants_scope, target: tenants_user, content: { base_pricing: true })
      export_margin = FactoryBot.create(:export_margin, applicable: tenants_user, tenant: tenants_tenant, origin_hub_id: lcl_local_charge.hub_id)
      FactoryBot.create(:pricings_detail, margin: export_margin, operator: '+', charge_category: FactoryBot.create(:legacy_charge_categories, code: 'isps', tenant: tenant))
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)

      local_charges_data = described_class.new(user: user, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING & CONSOLIDATION)' do
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)
      scope = FactoryBot.create(:tenants_scope, target: tenants_user, content: { base_pricing: true, consolidation: { cargo: { backend: true } } })
      FactoryBot.create(:export_margin, applicable: tenants_tenant, tenant: tenants_tenant)
      local_charges_data, metadata = described_class.new(user: user, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING & multiple groups)' do
      user_mg = FactoryBot.create(:legacy_user, tenant: tenant)
      tenants_user_mg = Tenants::User.find_by(legacy_id: user_mg.id)
      group_1 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST1')
      FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user_mg)
      group_2 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST2')
      FactoryBot.create(:tenants_membership, group: group_2, member: tenants_user_mg)
      group_local_charge_1 = FactoryBot.create(:legacy_local_charge,
                                               tenant: tenant,
                                               hub: origin_hub,
                                               mode_of_transport: 'ocean',
                                               load_type: 'lcl',
                                               direction: 'export',
                                               tenant_vehicle: tenant_vehicle_1,
                                               fees: lcl_local_charge_fees,
                                               effective_date: Date.today,
                                               expiration_date: Date.today + 3.months,
                                               group_id: group_1.id)
      FactoryBot.create(:legacy_local_charge,
                        tenant: tenant,
                        hub: origin_hub,
                        mode_of_transport: 'ocean',
                        load_type: 'lcl',
                        direction: 'export',
                        tenant_vehicle: tenant_vehicle_1,
                        fees: lcl_local_charge_fees,
                        effective_date: Date.today,
                        expiration_date: Date.today + 3.months,
                        group_id: group_2.id)
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)
      scope = FactoryBot.create(:tenants_scope, target: tenants_user_mg, content: { base_pricing: true })
      FactoryBot.create(:export_margin, applicable: tenants_tenant, tenant: tenants_tenant)
      local_charges_data, metadata = described_class.new(user: user_mg, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user_mg)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
      expect(local_charges_data.values.dig(0, 0, 0)['id']).to eq(group_local_charge_1.id)
    end

    it 'returns the correct number of charges for single cargo classes (LCL)' do
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)
      local_charges_data, metadata = described_class.new(user: user, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
    end
  end

  describe '.determine_local_charges' do
    it 'returns the correct number of charges for multiple cargo classes (FCL)' do
      fcl_20 = FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_20', cargo_class: 'fcl_20')
      fcl_40 = FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_40', cargo_class: 'fcl_40')
      fcl_40_hq = FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_40_hq', cargo_class: 'fcl_40_hq')
      cargos = [fcl_20, fcl_40, fcl_40_hq]
      local_charges_data, _metadata = described_class.new(user: user, shipment: shipment).determine_local_charges(fcl_schedules, cargos, 'export', user)
      expect(local_charges_data.values.length).to eq(1)
      expect(local_charges_data.values.first.length).to eq(4)
      expect(local_charges_data.values.first.pluck('key')).to match_array([fcl_20.id, fcl_40.id, fcl_40_hq.id, 'shipment'])
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING)' do
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)
      scope = FactoryBot.create(:tenants_scope, target: tenants_user, content: { base_pricing: true })
      FactoryBot.create(:export_margin, applicable: tenants_tenant, tenant: tenants_tenant)
      local_charges_data, _metadata = described_class.new(user: user, shipment: shipment).determine_local_charges(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.length).to eq(1)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.first.pluck('key')).to match_array([lcl.id, 'shipment'])
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING & multiple groups)' do
      user_mg = FactoryBot.create(:legacy_user, tenant: tenant)
      tenants_user_mg = Tenants::User.find_by(legacy_id: user_mg.id)
      group_1 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST1')
      FactoryBot.create(:tenants_membership, group: group_1, member: tenants_user_mg)
      group_2 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'TEST2')
      FactoryBot.create(:tenants_membership, group: group_2, member: tenants_user_mg)
      group_local_charge_1 = FactoryBot.create(:legacy_local_charge,
                                               tenant: tenant,
                                               hub: origin_hub,
                                               mode_of_transport: 'ocean',
                                               load_type: 'lcl',
                                               direction: 'export',
                                               tenant_vehicle: tenant_vehicle_1,
                                               fees: lcl_local_charge_fees,
                                               effective_date: Date.today,
                                               expiration_date: Date.today + 3.months,
                                               group_id: group_1.id)
      FactoryBot.create(:legacy_local_charge,
                        tenant: tenant,
                        hub: origin_hub,
                        mode_of_transport: 'ocean',
                        load_type: 'lcl',
                        direction: 'export',
                        tenant_vehicle: tenant_vehicle_1,
                        fees: lcl_local_charge_fees,
                        effective_date: Date.today,
                        expiration_date: Date.today + 3.months,
                        group_id: group_2.id)
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)
      scope = FactoryBot.create(:tenants_scope, target: tenants_user_mg, content: { base_pricing: true })
      FactoryBot.create(:export_margin, applicable: tenants_tenant, tenant: tenants_tenant)
      local_charges_data, _metadata = described_class.new(user: user_mg, shipment: shipment).determine_local_charges(lcl_schedules, [lcl], 'export', user_mg)
      expect(local_charges_data.values.length).to eq(1)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.first.pluck('key')).to match_array([lcl.id, 'shipment'])
    end

    it 'returns the correct number of charges for single cargo classes (LCL)' do
      lcl = FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id)
      local_charges_data, _metadata = described_class.new(user: user, shipment: shipment).determine_local_charges(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
    end

    context 'with backend consolidation' do
      before do
        Tenants::Scope.find_by(target: tenants_tenant).update(content: { consolidation: { cargo: { backend: true } } })
      end

      let(:cargos) { FactoryBot.create_list(:legacy_cargo_item, 3, shipment_id: shipment.id) }

      it 'returns the correct number of objects for consolidation scope' do
        local_charges_data, _metadata = described_class.new(user: user, shipment: shipment).determine_local_charges(lcl_schedules, cargos, 'export', user)
        expect(local_charges_data.values.first.length).to eq(2)
        expect(local_charges_data.values.length).to eq(1)
      end
    end
  end

  describe '.cargo_hash_for_local_charges' do
    context 'without backend consolidation' do
      it 'returns the correct number of objects for consolidation scope = false' do
        fcl_20 = FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_20', cargo_class: 'fcl_20')
        fcl_40 = FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_40', cargo_class: 'fcl_40')
        fcl_40_hq = FactoryBot.create(:legacy_container, shipment_id: shipment.id, size_class: 'fcl_40_hq', cargo_class: 'fcl_40_hq')
        cargos = [fcl_20, fcl_40, fcl_40_hq]
        klass = described_class.new(user: user, shipment: shipment)
        cargo_objects = klass.cargo_hash_for_local_charges(cargos: cargos, mot: 'ocean')
        expect(cargo_objects.length).to eq(3)
      end
    end
  end

  describe '.handle_range_fee' do
    let(:fee) do
      {
        'key' => 'THC',
        'rate' => 0.5e1,
        'rate_basis' => 'PER_CBM_RANGE',
        'currency' => 'EUR',
        'min' => 0.5e1,
        'range' => [{ 'max' => 10.0, 'min' => 0.0, 'cbm' => 20 }, { 'max' => 100.0, 'min' => 10.0, 'cbm' => 110.0 }]
      }.with_indifferent_access
    end
    let(:metadata_id) { SecureRandom.uuid }
    let(:metadata) do
      [
        {
          metadata_id: metadata_id,
          fees: {
            THC: {
              breakdowns: [
                {
                  adjusted_rate: {
                    range: [
                      { 'max' => 100.0, 'min' => 10.0, 'rate' => 15.0 }
                    ]
                  }
                }
              ]
            }
          }
        }
      ]
    end

    subject { described_class.new(user: user, shipment: shipment) }

    context 'PER_CBM_RANGE' do
      it 'returns the correct fee_range for the larger volume' do
        cargo_hash = { weight_measure: 11, volume: 11, weight: 11_000, raw_weight: 11_000, quantity: 9 }
        value = subject.handle_range_fee(fee: fee, cargo: cargo_hash, metadata_id: metadata_id)
        expect(value).to eq(110)
      end

      it 'returns the correct fee_range for the smaller volume' do
        cargo_hash = { weight_measure: 4, volume: 4, raw_weight: 4000, weight: 4000, quantity: 9 }
        value = subject.handle_range_fee(fee: fee, cargo: cargo_hash, metadata_id: metadata_id)
        expect(value).to eq(20)
      end
    end

    context 'PER_WM_RANGE' do
      let(:fee) do
        {
          'rate' => 0.5e1,
          'rate_basis' => 'PER_WM_RANGE',
          'currency' => 'EUR',
          'min' => 0.5e1,
          'range' => [{ 'max' => 10.0, 'min' => 0.0, 'rate' => 5.0 }, { 'max' => 100.0, 'min' => 10.0, 'rate' => 10.0 }]
        }
      end

      it 'returns the correct fee_range for the weight_measure' do
        cargo_hash = { weight_measure: 11, volume: 11, weight: 11_000, raw_weight: 11_000, quantity: 9 }
        value = subject.handle_range_fee(fee: fee, cargo: cargo_hash, metadata_id: metadata_id)
        expect(value).to eq(10)
      end
    end
  end

  describe '.determine_cargo_freight_price' do
    let(:agg_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
    let(:lcl_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id) }
    let(:fcl_20_cargo) { FactoryBot.create(:legacy_container, shipment_id: shipment.id) }
    let(:overweight_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id, cargo_item_type_id: pallet.id, payload_in_kg: 3000) }
    let(:agg_cargo) { FactoryBot.create(:legacy_aggregated_cargo, shipment_id: agg_shipment.id) }
    let(:consolidated_cargo) do
      {
        id: 'ids',
        dimension_x: 240,
        dimension_y: 160,
        dimension_z: 240,
        volume: 3.748,
        payload_in_kg: 600,
        cargo_class: 'lcl',
        chargeable_weight: 3748,
        num_of_items: 2,
        quantity: 1
      }
    end
    let!(:per_container_range_rate_basis) { FactoryBot.create(:legacy_rate_basis, external_code: 'PER_CONTAINER_RANGE', internal_code: 'PER_UNIT_RANGE') }
    let(:fat_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id, cargo_item_type_id: pallet.id, payload_in_kg: 2200) }

    it 'it calculates the correct price for PER_WM' do
      wm_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_wm, priceable: wm_pricing, tenant: tenant)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(
        cargo: lcl_cargo,
        pricing: wm_pricing.as_json.dig('data'),
        user: user,
        mode_of_transport: 'ocean'
      )
      expect(result.dig('total', 'value')).to eq(222.2)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_hbl' do
      hbl_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_hbl, tenant: tenant, priceable: hbl_pricing)
      FactoryBot.create(:legacy_rate_basis, external_code: 'PER_HBL', internal_code: 'PER_SHIPMENT')
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: hbl_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(1111)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_shipment' do
      shipment_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_shipment, tenant: tenant, priceable: shipment_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: shipment_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(1111)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_item' do
      item_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_item, tenant: tenant, priceable: item_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: item_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(1111)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_cbm' do
      cbm_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_cbm, tenant: tenant, priceable: cbm_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: cbm_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(8.888)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_kg' do
      kg_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_kg, tenant: tenant, priceable: kg_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: kg_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(222_200)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_ton' do
      ton_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_ton, tenant: tenant, priceable: ton_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: ton_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(222.2)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_kg_range' do
      kg_range_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_kg_range, tenant: tenant, priceable: kg_range_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: lcl_cargo,
                                                                                                 pricing: kg_range_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(1600)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_kg_range when out of range' do
      kg_range_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_kg_range, tenant: tenant, priceable: kg_range_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: overweight_cargo,
                                                                                                 pricing: kg_range_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(18_000)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_cbm_kg_heavy' do
      cbm_kg_heavy_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_cbm_kg_heavy, tenant: tenant, priceable: cbm_kg_heavy_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: overweight_cargo,
                                                                                                 pricing: cbm_kg_heavy_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(12)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_item_heavy below limit' do
      item_heavy_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_cbm_kg_heavy, tenant: tenant, priceable: item_heavy_pricing, hw_threshold: 50_000)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(
        cargo: lcl_cargo,
        pricing: item_heavy_pricing.as_json.dig('data'),
        user: user,
        mode_of_transport: 'ocean'
      )
      expect(result.dig('total', 'value')).to eq(0)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_item_heavy' do
      item_heavy_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_item_heavy, tenant: tenant, priceable: item_heavy_pricing)

      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: fat_cargo,
                                                                                                 pricing: item_heavy_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(250)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_item_heavy beyond range' do
      item_heavy_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_item_heavy, tenant: tenant, priceable: item_heavy_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: overweight_cargo,
                                                                                                 pricing: item_heavy_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(250)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_container_range' do
      container_range_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_container_range, tenant: tenant, priceable: container_range_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: fcl_20_cargo,
                                                                                                 pricing: container_range_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(100)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_container_range above range' do
      fat_fcl_20_cargo = FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: shipment.id, payload_in_kg: 24_000, quantity: 25)
      container_range_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_container_range, tenant: tenant, priceable: container_range_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: fat_fcl_20_cargo,
                                                                                                 pricing: container_range_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(60)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'it calculates the correct price for per_unit_range above range' do
      fat_fcl_20_cargo = FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: shipment.id, payload_in_kg: 24_000)
      unit_range_pricing = FactoryBot.create(:legacy_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:pd_per_unit_range, tenant: tenant, priceable: unit_range_pricing)
      result = described_class.new(user: user, shipment: shipment).determine_cargo_freight_price(cargo: fcl_20_cargo,
                                                                                                 pricing: unit_range_pricing.as_json.dig('data'),
                                                                                                 user: user,
                                                                                                 mode_of_transport: 'ocean')
      expect(result.dig('total', 'value')).to eq(100)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end
  end

  describe '.calc_addon_charges' do
    let(:addon) { FactoryBot.create(:legacy_addon, tenant_id: tenant.id, hub: origin_hub) }
    let(:uknown_addon) { FactoryBot.create(:unknown_fee_addon, tenant_id: tenant.id, hub: origin_hub) }
    let(:addon_fcl) { FactoryBot.create(:legacy_addon, tenant_id: tenant.id, hub: origin_hub, cargo_class: 'fcl_20') }
    let(:lcl) { FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id) }
    let(:lcl) { FactoryBot.create(:legacy_cargo_item, shipment_id: shipment.id) }

    it 'calculates the addon charge for cargo item' do
      result = described_class.new(user: user, shipment: shipment)
                              .calc_addon_charges(
                                cargos: [lcl],
                                charge: addon.fees,
                                user: user,
                                mode_of_transport: 'ocean'
                              )
      expect(result.dig('total', 'value')).to eq(75)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'calculates the addon charge for cargo item w/ unknown fee' do
      result = described_class.new(user: user, shipment: shipment)
                              .calc_addon_charges(
                                cargos: [lcl],
                                charge: uknown_addon.fees,
                                user: user,
                                mode_of_transport: 'ocean'
                              )
      expect(result.dig('total', 'value')).to eq(0)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end

    it 'calculates the addon charge for container' do
      result = described_class.new(user: user, shipment: shipment)
                              .calc_addon_charges(
                                cargos: [fcl_20],
                                charge: addon_fcl.fees,
                                user: user,
                                mode_of_transport: 'ocean'
                              )
      expect(result.dig('total', 'value')).to eq(75)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end
  end

  describe '.get_cargo_weight' do
    let(:agg_cargo) { FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id) }
    it 'calculates the addon charge' do
      weight, chargeable_weight = described_class.new(user: user, shipment: shipment)
                              .get_cargo_weights(cargo: agg_cargo, mot: 'ocean')
      expect(weight).to eq(200)
      expect(chargeable_weight).to eq(1000)
    end
  end

  describe '.get_cargo_hash' do
    let(:consolidated_cargo) do
      {
        volume: 1.2,
        chargeable_weight: 1500,
        num_of_items: 2
      }
    end
    it 'creturns the cargo object' do
      result = described_class.new(user: user, shipment: shipment)
                              .get_cargo_hash(consolidated_cargo, 'ocean')
      expect(result[:volume]).to eq(consolidated_cargo[:volume])
      expect(result[:weight]).to eq(consolidated_cargo[:chargeable_weight])
      expect(result[:quantity]).to eq(consolidated_cargo[:num_of_items])
    end
  end

  describe '.fee_value' do
    let(:klass) { described_class.new(user: user, shipment: shipment) }
    context 'with CBM_TON_RANGE rate basis' do
      let(:fee) do
        {
          'key' => 'QDF',
          'max' => nil,
          'min' => 57,
          'name' => 'Wharfage / Quay Dues',
          'range' => [{ 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' }, { 'cbm' => 8, 'max' => 12, 'min' => 6, 'currency' => 'EUR' }],
          'currency' => 'EUR',
          'rate_basis' => 'PER_UNIT_TON_CBM_RANGE'
        }
      end

      it 'calculates the PER_CBM_TON_RANGE in favour of CBM' do
        fee = {
          'key' => 'QDF',
          'max' => nil,
          'min' => 57,
          'name' => 'Wharfage / Quay Dues',
          'range' => [{ 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' }, { 'cbm' => 8, 'max' => 40, 'min' => 6, 'currency' => 'EUR' }],
          'currency' => 'EUR',
          'rate_basis' => 'PER_UNIT_TON_CBM_RANGE'
        }
        cargo_hash = {
          volume: 6,
          weight: 500,
          raw_weight: 500,
          weight_measure: 6
        }
        result = klass.fee_value(fee: fee, cargo: cargo_hash, rounding: true)
        expect(result).to eq(57)
      end

      it 'calculates the PER_CBM_TON_RANGE out of range' do
        fee = {
          'key' => 'QDF',
          'max' => nil,
          'min' => 57,
          'name' => 'Wharfage / Quay Dues',
          'range' => [{ 'max' => 5, 'min' => 0, 'ton' => 41, 'currency' => 'EUR' }],
          'currency' => 'EUR',
          'rate_basis' => 'PER_UNIT_TON_CBM_RANGE'
        }
        cargo_hash = {
          volume: 6,
          weight: 500,
          raw_weight: 500,
          weight_measure: 6
        }
        result = klass.fee_value(fee: fee, cargo: cargo_hash, rounding: true)
        expect(result).to eq(57)
      end

      it 'calculates the PER_SHIPMENT_TON' do
        fee = {
          'key' => 'THC',
          'max' => nil,
          'min' => 57,
          'rate' => 100,
          'name' => 'A Fee',
          'currency' => 'EUR',
          'rate_basis' => 'PER_SHIPMENT_TON'
        }
        cargo_hash = {
          volume: 2,
          weight: 2500,
          raw_weight: 2500,
          weight_measure: 2.5
        }
        result = klass.fee_value(fee: fee, cargo: cargo_hash, rounding: true)
        expect(result).to eq(250)
      end

      it 'calculates the PER_CBM_TON in favour of ton' do
        fee = {
          'key' => 'THC',
          'max' => nil,
          'min' => 57,
          'ton' => 100,
          'cbm' => 100,
          'name' => 'A Fee',
          'currency' => 'EUR',
          'rate_basis' => 'PER_CBM_TON'
        }
        cargo_hash = {
          volume: 2,
          weight: 2500,
          raw_weight: 2500,
          weight_measure: 2.5
        }
        result = klass.fee_value(fee: fee, cargo: cargo_hash, rounding: true)
        expect(result).to eq(250)
      end

      it 'calculates the PER_CBM_TON in favour of cbm' do
        fee = {
          'key' => 'THC',
          'max' => nil,
          'min' => 57,
          'ton' => 100,
          'cbm' => 100,
          'name' => 'A Fee',
          'currency' => 'EUR',
          'rate_basis' => 'PER_CBM_TON'
        }
        cargo_hash = {
          volume: 3,
          weight: 2500,
          raw_weight: 2500,
          weight_measure: 3
        }
        result = klass.fee_value(fee: fee, cargo: cargo_hash, rounding: true)
        expect(result).to eq(300)
      end

      it 'calculates the PER_X_KG_FLAT' do
        fee = {
          'key' => 'THC',
          'max' => nil,
          'min' => 57,
          'base' => 100,
          'value' => 50,
          'name' => 'A Fee',
          'currency' => 'EUR',
          'rate_basis' => 'PER_X_KG_FLAT'
        }
        cargo_hash = {
          volume: 3,
          weight: 2001,
          raw_weight: 2001,
          weight_measure: 3
        }
        result = klass.fee_value(fee: fee, cargo: cargo_hash, rounding: true)
        expect(result).to eq(0.105e6)
      end
    end
  end
end
