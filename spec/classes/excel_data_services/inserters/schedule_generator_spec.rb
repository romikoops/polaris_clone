# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::ScheduleGenerator do
  describe '.perform' do
    let(:carrier) { create(:carrier) }
    let(:data) do
      [
        { origin: 'DALIAN', destination: 'FELIXSTOWE', transit_time: 38, carrier: 'Hapag Lloyd', service_level: nil, cargo_class: 'container', row_nr: 2, ordinals: [4] },
        { origin: 'DALIAN', destination: 'FELIXSTOWE', transit_time: 38, carrier: nil, service_level: nil, cargo_class: 'cargo_item', row_nr: 2, ordinals: [4] }
      ]
    end
    let(:tenant) { create(:tenant) }
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
             tenant_vehicles: [tenant_vehicle_1])
    end
    let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'cargo_item', tenant: tenant) }
    let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'container', tenant: tenant) }

    let!(:itinerary) { create(:itinerary, tenant: tenant, name: 'Dalian - Felixstowe') }

    context 'without base pricing' do
      before do
        create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_1, transport_category: cargo_transport_category)
        create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2, transport_category: fcl_20_transport_category)
        create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2, transport_category: fcl_40_transport_category)
        create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2, transport_category: fcl_40_hq_transport_category)
      end

      it 'creates the trips for the correct itineraries' do
        stats = Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
          described_class.insert(tenant: tenant, data: data, options: {})
        end
        aggregate_failures do
          expect(stats.dig(:trips, :number_created)).to eq(24)
          expect(itinerary.trips.where(load_type: 'cargo_item').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_1.id])
          expect(itinerary.trips.where(load_type: 'container').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_2.id])
          expect(itinerary.trips.pluck(:start_date).map { |d| d.strftime('%^A') }.uniq).to eq(['THURSDAY'])
        end
      end
    end

    context 'with base pricing' do
      before do
        create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_1)
        create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2)
        create(:fcl_40_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2)
        create(:fcl_40_hq_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2)
        FactoryBot.create(:tenants_scope, target: Tenants::Tenant.find_by(legacy_id: tenant.id), content: { base_pricing: true })
      end

      it 'creates the trips for the correct itineraries with base pricing' do
        stats = Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
          described_class.insert(tenant: tenant, data: data, options: {})
        end

        aggregate_failures do
          expect(stats.dig(:trips, :number_created)).to eq(24)
          expect(itinerary.trips.where(load_type: 'cargo_item').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_1.id])
          expect(itinerary.trips.where(load_type: 'container').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_2.id])
          expect(itinerary.trips.pluck(:start_date).map { |d| d.strftime('%^A') }.uniq).to eq(['THURSDAY'])
        end
      end
    end
  end
end
