# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::DatabaseInserter::ScheduleGenerator do
  describe '.perform' do
    let(:data) do
      [
        { origin: 'DALIAN', destination: 'FELIXSTOWE', transit_time: 38, cargo_class: 'container', row_nr: 2, ordinals: [4] },
        { origin: 'DALIAN', destination: 'FELIXSTOWE', transit_time: 38, cargo_class: 'cargo_item', row_nr: 2, ordinals: [4] }
      ]
    end
    let(:tenant) { create(:tenant) }
    let(:klass_identifier) { 'ScheduleGenerator' }
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
    let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'cargo_item') }
    let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'container') }

    let!(:itinerary) { create(:itinerary, tenant: tenant, name: 'Dalian - Felixstowe') }
    let!(:pricing_lcl) { create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_1, transport_category: cargo_transport_category) }
    let!(:pricing_fcl_20) { create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2, transport_category: fcl_20_transport_category) }
    let!(:pricing_fcl_40) { create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2, transport_category: fcl_40_transport_category) }
    let!(:pricing_fcl_40_hq) { create(:pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle_2, transport_category: fcl_40_hq_transport_category) }

    it 'creates the trips for the correct itineraries' do
      stats = Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
        described_class.insert(tenant: tenant, klass_identifier: klass_identifier, data: data, options: {})
      end
      expect(stats.dig(:trips, :number_updated)).to eq(24)
      expect(itinerary.trips.where(load_type: 'cargo_item').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_1.id])
      expect(itinerary.trips.where(load_type: 'container').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_2.id])
      expect(itinerary.trips.pluck(:start_date).map { |d| d.strftime('%^A') }.uniq).to eq(['THURSDAY'])
    end
  end
end
