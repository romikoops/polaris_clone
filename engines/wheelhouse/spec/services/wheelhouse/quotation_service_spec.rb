# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::QuotationService do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  let(:itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant) }
  let(:air_itinerary) { FactoryBot.create(:hamburg_shanghai_itinerary, mode_of_transport: 'air', tenant: tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:origin_airport) { air_itinerary.hubs.find_by(name: 'Hamburg Port') }
  let(:destination_airport) { air_itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly') }
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:shipping_info) do
    {
      trucking_info: { pre_carriage: { truck_type: '' }, on_carriage: { truck_type: '' } }
    }
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
  let(:input) do
    { tenant_id: tenant.id,
      user_id: tenants_user.id,
      direction: direction,
      load_type: load_type,
      selected_date: Time.zone.today }
  end
  let!(:tenants_scope) { FactoryBot.create(:tenants_scope, target: tenants_tenant, content: { base_pricing: true }) }
  let(:port_to_port_input) do
    input[:origin] = { nexus_id: origin_hub.nexus_id }
    input[:destination] = { nexus_id: destination_hub.nexus_id }
    input
  end

  before do
    [itinerary, air_itinerary].product(%w[container cargo_item]).each do |it, load|
      FactoryBot.create(:trip_with_layovers, itinerary: it, load_type: load, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:trip_with_layovers,
                        itinerary: it,
                        load_type: load,
                        tenant_vehicle: tenant_vehicle,
                        start_date: 10.days.from_now,
                        end_date: 30.days.from_now)
    end
    FactoryBot.create(:legacy_tenant_cargo_item_type, cargo_item_type: pallet, tenant: tenant)
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    FactoryBot.create(:lcl_pricing, itinerary: air_itinerary, tenant: tenant, tenant_vehicle: tenant_vehicle)
    %w[ocean trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_on_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:trucking_pre_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:import_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0),
        FactoryBot.create(:export_margin, default_for: mot, tenant: tenants_tenant, applicable: tenants_tenant, value: 0)
      ]
    end
  end

  describe '.perform' do
    context 'when port to port (defaults)' do
      let(:service) { described_class.new(quotation_details: port_to_port_input.with_indifferent_access, shipping_info: shipping_info) }

      it 'perform a booking calulation' do
        results = service.results
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(1)
        end
      end

      it 'returns results as tenders for serialization' do
        results = service.results
        tender = service.tenders.first.object
        expect(tender.to_h.keys).to match(results.first.keys)
      end
    end

    context 'when port to port (defaults & quote & container)' do
      before { tenants_scope.update(content: { base_pricing: true, closed_quotation_tool: true }) }

      let(:load_type) { 'container' }
      let(:service) { described_class.new(quotation_details: port_to_port_input.with_indifferent_access, shipping_info: shipping_info) }

      it 'perform a quote calulation' do
        results = service.results
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(250)
        end
      end
    end

    context 'when port to port (with cargo)' do
      let(:shipping_info) do
        {
          cargo_items_attributes: cargo_item_attributes
        }
      end
      let(:service) { described_class.new(quotation_details: port_to_port_input.with_indifferent_access, shipping_info: shipping_info) }

      it 'perform a booking calulation' do
        results = service.results
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(%i[quote schedules meta notes])
          expect(results.first.dig(:quote, :total, :value)).to eq(28.8)
        end
      end
    end
  end
end
