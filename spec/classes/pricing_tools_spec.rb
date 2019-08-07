# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PricingTools do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { create(:tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:cargo_transport_category) do
    create(:transport_category, cargo_class: 'lcl', load_type: 'cargo_item')
  end
  let(:fcl_20_transport_category) do
    create(:transport_category, cargo_class: 'fcl_20', load_type: 'container')
  end
  let(:fcl_40_transport_category) do
    create(:transport_category, cargo_class: 'fcl_40', load_type: 'container')
  end
  let(:fcl_40_hq_transport_category) do
    create(:transport_category, cargo_class: 'fcl_40_hq', load_type: 'container')
  end
  let(:vehicle) do
    create(:vehicle,
           transport_categories: [
             fcl_20_transport_category,
             fcl_40_transport_category,
             fcl_40_hq_transport_category,
             cargo_transport_category
           ],
           tenant_vehicles: [tenant_vehicle_1, tenant_vehicle_2])
  end
  let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'slowly') }
  let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'express') }
  let(:fcl_trips) do
    [
      create(:trip, load_type: 'container', tenant_vehicle: tenant_vehicle_1),
      create(:trip, load_type: 'container', tenant_vehicle: tenant_vehicle_2)
    ]
  end
  let(:lcl_trips) do
    [
      create(:trip, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_1),
      create(:trip, load_type: 'cargo_item', tenant_vehicle: tenant_vehicle_2)
    ]
  end
  let(:all_trips) { lcl_trips | fcl_trips }
  let(:user) { create(:user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:group) { create(:tenants_group, tenant: tenants_tenant, name: 'TEST') }
  let(:membership) { create(:tenants_membership, group: group, member: tenants_user) }
  let(:shipment) { create(:shipment, load_type: load_type, direction: direction, user: user, tenant: tenant, origin_nexus: origin_nexus, destination_nexus: destination_nexus, trip: itinerary.trips.first, itinerary: itinerary) }
  let(:origin_nexus) { create(:nexus, hubs: [origin_hub]) }
  let(:destination_nexus) { create(:nexus, hubs: [destination_hub]) }
  let!(:itinerary) { create(:itinerary, tenant: tenant, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: fcl_trips | lcl_trips) }
  let(:origin_hub) { create(:hub, tenant: tenant) }
  let(:destination_hub) { create(:hub, tenant: tenant) }
  let(:origin_stop) { create(:stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { create(:stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { create(:layover, stop_index: 0, trip: fcl_trips.first) }
  let(:destination_layover) { create(:layover, stop_index: 1, trip: fcl_trips.first) }
  let(:fcl_local_charge_fees) do
    { 'ADI' => { 'key' => 'ADI', 'max' => nil, 'min' => nil, 'name' => 'Admin Fee', 'value' => 27.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ECA' => { 'key' => 'ECA', 'max' => nil, 'min' => nil, 'name' => 'ECA/LSF', 'value' => 50, 'currency' => 'USD', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'FILL' =>
   { 'key' => 'FILL', 'max' => nil, 'min' => nil, 'name' => 'Filling Charges', 'value' => 35, 'currency' => 'EUR', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ISPS' => { 'key' => 'ISPS', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 25, 'currency' => 'EUR', 'rate_basis' => 'PER_CONTAINER', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' } }
  end
  let(:lcl_local_charge_fees) do
    { 'ADI' => { 'key' => 'ADI', 'max' => nil, 'min' => nil, 'name' => 'Admin Fee', 'value' => 27.5, 'currency' => 'EUR', 'rate_basis' => 'PER_SHIPMENT', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ECA' => { 'key' => 'ECA', 'max' => nil, 'min' => nil, 'name' => 'ECA/LSF', 'value' => 50, 'currency' => 'USD', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'FILL' =>
   { 'key' => 'FILL', 'max' => nil, 'min' => nil, 'name' => 'Filling Charges', 'value' => 35, 'currency' => 'EUR', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' },
      'ISPS' => { 'key' => 'ISPS', 'max' => nil, 'min' => nil, 'name' => 'ISPS', 'value' => 25, 'currency' => 'EUR', 'rate_basis' => 'PER_ITEM', 'effective_date' => '2018-04-16', 'expiration_date' => '2018-05-15' } }
  end
  let!(:local_charge_margin) { create(:export_margin, tenant: tenants_tenant, origin_hub: origin_hub)}
  let!(:lcl_local_charge) do
    create(:local_charge,
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
    create(:local_charge,
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
    create(:local_charge,
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
    create(:local_charge,
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
    create(:local_charge,
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
      Legacy::Schedule.from_trip(trip)
    end
  end
  let(:lcl_schedules) do
    lcl_trips.map do |trip|
      Legacy::Schedule.from_trip(trip)
    end
  end

  describe '.find_local_charges' do
    it 'returns the correct number of charges for multiple cargo classes (FCL)' do
      fcl_20 = create(:container, shipment_id: shipment.id, size_class: 'fcl_20', cargo_class: 'fcl_20')
      fcl_40 = create(:container, shipment_id: shipment.id, size_class: 'fcl_40', cargo_class: 'fcl_40')
      fcl_40_hq = create(:container, shipment_id: shipment.id, size_class: 'fcl_40_hq', cargo_class: 'fcl_40_hq')
      cargos = [fcl_20, fcl_40, fcl_40_hq]
      local_charges_data = described_class.new(user: user, shipment: shipment).find_local_charge(fcl_schedules, cargos, 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.first.first.length).to eq(3)
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING)' do
      lcl = create(:cargo_item, shipment_id: shipment.id)
      scope = create(:tenants_scope, target: tenants_user, content: {base_pricing: true})
      create(:export_margin, applicable: tenants_tenant, tenant: tenants_tenant)
      local_charges_data = described_class.new(user: user, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
    end

    it 'returns the correct number of charges for single cargo classes (LCL & BASE PRICING & multiple groups)' do
      user_mg = create(:user, tenant: tenant)
      tenants_user_mg = Tenants::User.find_by(legacy_id: user_mg.id)
      group_1 = create(:tenants_group, tenant: tenants_tenant, name: 'TEST1')
      create(:tenants_membership, group: group_1, member: tenants_user_mg)
      group_2 = create(:tenants_group, tenant: tenants_tenant, name: 'TEST2')
      create(:tenants_membership, group: group_2, member: tenants_user_mg)
      group_local_charge_1 = create(:local_charge,
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
      create(:local_charge,
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
      lcl = create(:cargo_item, shipment_id: shipment.id)
      scope = create(:tenants_scope, target: tenants_user_mg, content: {base_pricing: true})
      create(:export_margin, applicable: tenants_tenant, tenant: tenants_tenant)
      local_charges_data = described_class.new(user: user_mg, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user_mg)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
      expect(local_charges_data.values.dig(0,0,0)['id']).to eq(group_local_charge_1.id)
    end

    it 'returns the correct number of charges for single cargo classes (LCL)' do
      lcl = create(:cargo_item, shipment_id: shipment.id)
      local_charges_data = described_class.new(user: user, shipment: shipment).find_local_charge(lcl_schedules, [lcl], 'export', user)
      expect(local_charges_data.values.first.length).to eq(2)
      expect(local_charges_data.values.length).to eq(1)
    end
  end

  describe '.cargo_hash_for_local_charges' do
    context 'with backend consolidation' do
      it 'returns the correct number of objects for consolidation scope' do
        fcl_20 = create(:container, shipment_id: shipment.id, size_class: 'fcl_20', cargo_class: 'fcl_20')
        fcl_40 = create(:container, shipment_id: shipment.id, size_class: 'fcl_40', cargo_class: 'fcl_40')
        fcl_40_hq = create(:container, shipment_id: shipment.id, size_class: 'fcl_40_hq', cargo_class: 'fcl_40_hq')
        cargos = [fcl_20, fcl_40, fcl_40_hq]
        klass= described_class.new(user: user, shipment: shipment)
        consolidated_hash = klass.consolidated_cargo_hash(cargos)
        scope = { cargo: { backend: true } }.with_indifferent_access
        cargo_objects = klass.cargo_hash_for_local_charges(cargos, consolidated_hash, scope)
        expect(cargo_objects.length).to eq(1)
      end
    end

    context 'without backend consolidation' do
      it 'returns the correct number of objects for consolidation scope = false' do
        fcl_20 = create(:container, shipment_id: shipment.id, size_class: 'fcl_20', cargo_class: 'fcl_20')
        fcl_40 = create(:container, shipment_id: shipment.id, size_class: 'fcl_40', cargo_class: 'fcl_40')
        fcl_40_hq = create(:container, shipment_id: shipment.id, size_class: 'fcl_40_hq', cargo_class: 'fcl_40_hq')
        cargos = [fcl_20, fcl_40, fcl_40_hq]
        klass= described_class.new(user: user, shipment: shipment)
        consolidated_hash = klass.consolidated_cargo_hash(cargos)
        scope = { cargo: { backend: false } }.with_indifferent_access
        cargo_objects = klass.cargo_hash_for_local_charges(cargos, consolidated_hash, scope)
        expect(cargo_objects.length).to eq(3)
      end
    end
  end
end
