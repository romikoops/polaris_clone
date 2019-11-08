# frozen_string_literal: true

require 'rails_helper'
require 'timecop'
RSpec.describe Pricings::MarginCreator do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }

  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
  let!(:tenant_vehicles) do
    %w(slowly fast faster).map do |name|
      FactoryBot.create(:legacy_tenant_vehicle, name: name, tenant: tenant)
    end
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
  let!(:membership_1) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_20_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_hq_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:agg_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:lcl_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id) }
  let(:fcl_20_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_hq_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40_hq', shipment_id: fcl_40_hq_shipment.id) }
  let!(:itineraries) do
    [
      "Felixstowe - Fuzhou",
      "Felixstowe - Hangzhou",
      "Felixstowe - Jiangmen",
      "Felixstowe - Ningbo",
      "Felixstowe - Qingdao"
    ].map do |name|
      it = FactoryBot.create(:default_itinerary, name: name, tenant: tenant, mode_of_transport: 'ocean')
      %w(lcl fcl_20 fcl_40 fcl_40_hq).each do |cc|
        tenant_vehicles.each do |tv|
          FactoryBot.create(:pricings_pricing,
            itinerary: it,
            tenant_vehicle_id: tv.id,
            load_type: cc.to_sym,
            cargo_class: cc == 'lcl' ? 'cargo_item' : 'container')
        end
      end
      it
    end.flatten
  end
  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, tenant: tenant) }
  let!(:solas_charge_category) { FactoryBot.create(:solas_charge, tenant: tenant) }
  let!(:bas_charge_category) { FactoryBot.create(:bas_charge, tenant: tenant) }
  let!(:baf_charge_category) { FactoryBot.create(:baf_charge, tenant: tenant) }
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
  let(:wm_rate_basis) { double('WM Rate basis', external_code: 'PER_WM', internal_code: 'PER_WM') }
  let(:itinerary_1) { FactoryBot.create(:default_itinerary, tenant: tenant) }

  context 'freight margin creator' do
    describe '.perform' do
      it 'creates a margin for all itineraries, service levels and cargo classes' do
        args = {itinerary_ids: [],
          hub_ids: [],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "freight",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: [],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "itinerary",
          marginValue: "10",
          fineFeeValues: [],
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}

        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0.10)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.itinerary_id).to eq(nil)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.origin_hub_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
      end
      it 'creates a margin for one itinerary, all service levels and cargo classes' do
        args = {itinerary_ids: [itineraries.first.id],
          hub_ids: [],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "freight",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: [],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "itinerary",
          marginValue: "10",
          fineFeeValues: [],
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}
        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0.10)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.itinerary_id).to eq(itineraries.first.id)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.origin_hub_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
      end
      it 'creates a margin for one itinerary, all service levels and cargo classes with fee details' do
        args = {itinerary_ids: [itineraries.first.id],
          hub_ids: [],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "freight",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: [],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "itinerary",
          marginValue: "0",
          fineFeeValues:
             {"BAS - Basic Ocean Freight": {"operand": {"label": "percentage", "value": "%"}, "value": "10"}, "HAS - Heavy Weight Surcharge": {"operand": {"label": "addition", "value": "+"}, "value": "10"}},
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}

        new_margins = described_class.new(args).perform

        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.itinerary_id).to eq(itineraries.first.id)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.origin_hub_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
        expect(new_margins.first.details.length).to eq(2)
        expect(new_margins.first.details.select {|d| d.operator == '%'}.length).to eq(1)
        expect(new_margins.first.details.select {|d| d.operator == '+'}.length).to eq(1)
      end
      it 'creates a margin for one hub, all service levels and cargo classes' do
        hub = itineraries.first.stops.first.hub
        args = {itinerary_ids: [],
          hub_ids: [hub.id],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "freight",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: ['export'],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "hub",
          marginValue: "10",
          fineFeeValues: [],
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}
        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0.10)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.origin_hub_id).to eq(hub.id)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.itinerary_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
      end
      it 'creates a margin for multiple hubs, all service levels and multiple cargo classes' do
        hub_ids = Legacy::Hub.all.limit(2).ids
        args = {
          itinerary_ids: [],
          hub_ids: hub_ids,
          cargo_classes: ['fcl_20', 'fcl_40', 'fcl_40_hq'],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "freight",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: ['export'],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "hub",
          marginValue: "10",
          fineFeeValues: [],
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"
        }
        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(6)
        expect(new_margins.map(&:value).uniq).to eq([0.10])
        expect(new_margins.map(&:operator).uniq).to eq(['%'])
        expect(new_margins.map(&:applicable_type).uniq).to eq(['Tenants::Group'])
        expect(new_margins.map(&:tenant_vehicle_id).uniq).to eq([nil])
        expect(new_margins.map(&:origin_hub_id).uniq).to eq(hub_ids)
        expect(new_margins.map(&:cargo_class).uniq).to eq(["fcl_20", "fcl_40", "fcl_40_hq"])
        expect(new_margins.map(&:itinerary_id).uniq).to eq([nil])
        expect(new_margins.map(&:destination_hub_id).uniq).to eq([nil])
      end
    end
  end
  context 'trucking margin creator' do
    describe '.perform' do
      it 'creates a margin for one hub, all cargo classes' do
        hub = itineraries.first.stops.first.hub
        args = {itinerary_ids: [],
          hub_ids: [hub.id],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "trucking",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: ['export'],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "hub",
          marginValue: "10",
          fineFeeValues: [],
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}
        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0.10)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.origin_hub_id).to eq(hub.id)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.itinerary_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
      end
    end
  end
  context 'local charge margin creator' do
    describe '.perform' do
      it 'creates a margin for one hub, all cargo classes' do
        hub = itineraries.first.stops.first.hub
        args = {itinerary_ids: [],
          hub_ids: [hub.id],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "local_charges",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: ['export'],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "hub",
          marginValue: "10",
          fineFeeValues: [],
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}
        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0.10)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.origin_hub_id).to eq(hub.id)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.itinerary_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
      end
      it 'creates a margin for one hub, all cargo classes with fees' do
        hub = itineraries.first.stops.first.hub
        args = {itinerary_ids: [],
          hub_ids: [hub.id],
          cargo_classes: [],
          tenant_vehicle_ids: [],
          pricing_id: nil,
          selectedHubDirection: nil,
          marginType: "local_charges",
          tenant_id: tenant.id,
          groupId: group_1.id,
          directions: ['export'],
          operand: {"label": "percentage", "value": "%"},
          attached_to: "hub",
          marginValue: "10",
          fineFeeValues: {
            "DOC - Documentation": {
              "operand": {"label": "percentage", "value": "%"},
              "value": "10"
              },
            "HDL - Handling Fee": {
              "operand": {"label": "addition", "value": "+"}, "value": "10"
            }
          },
          effective_date: "2019-06-21T10:21:24.650Z",
          expiration_date: "2020-06-05T10:00:00.000Z"}
        new_margins = described_class.new(args).perform
        expect(new_margins.length).to eq(1)
        expect(new_margins.first.value).to eq(0.10)
        expect(new_margins.first.operator).to eq('%')
        expect(new_margins.first.applicable_type).to eq('Tenants::Group')
        expect(new_margins.first.tenant_vehicle_id).to eq(nil)
        expect(new_margins.first.origin_hub_id).to eq(hub.id)
        expect(new_margins.first.cargo_class).to eq('All')
        expect(new_margins.first.itinerary_id).to eq(nil)
        expect(new_margins.first.destination_hub_id).to eq(nil)
        expect(new_margins.first.details.length).to eq(2)
        expect(new_margins.first.details.select {|d| d.operator == '%'}.length).to eq(1)
        expect(new_margins.first.details.select {|d| d.operator == '+'}.length).to eq(1)
      end
    end
  end
end
