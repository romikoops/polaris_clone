# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::ScheduleGenerator do
  describe '.perform' do
    let(:data) do
      [
        { origin: 'Dalian', destination: 'Felixstowe', transit_time: 38, carrier: 'Hapag Lloyd', service_level: nil, mot: 'ocean', cargo_class: 'container', row_nr: 2, ordinals: [4] },
        { origin: 'Dalian', destination: 'Felixstowe', transit_time: 38, carrier: nil, service_level: nil, mot: 'ocean', cargo_class: 'cargo_item', row_nr: 2, ordinals: [4] },
        { origin: 'Shanghai', destination: 'Felixstowe', transit_time: 38, carrier: nil, service_level: nil, mot: nil, cargo_class: 'cargo_item', row_nr: 2, ordinals: [4] },
        { origin: 'Shanghai', destination: 'Felixstowe', transshipment: 'ZACPT', transit_time: 38, carrier: nil, service_level: nil, mot: nil, cargo_class: 'cargo_item', row_nr: 2, ordinals: [4] }
      ]
    end
    let(:tenant) { create(:tenant) }

    let(:vehicle) do
      create(:vehicle, tenant_vehicles: [tenant_vehicle_1])
    end
    let(:carrier) { create(:carrier, code: 'hapag lloyd', name: 'Hapag LLoyd') }
    let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'cargo_item', tenant: tenant) }
    let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'container', tenant: tenant, carrier: carrier) }

    let!(:itinerary) { create(:itinerary, tenant: tenant, name: 'Dalian - Felixstowe') }
    let!(:ignored_itinerary) { create(:itinerary, tenant: tenant, name: 'Dalian - Felixstowe', mode_of_transport: 'rail') }
    let!(:misspelled_itinerary) { create(:itinerary, tenant: tenant, name: 'Sahnghai - Felixstowe', mode_of_transport: 'air') }
    let!(:multi_mot_itineraries) do
      [
        create(:itinerary, tenant: tenant, name: 'Shanghai - Felixstowe', mode_of_transport: 'ocean'),
        create(:itinerary, tenant: tenant, name: 'Shanghai - Felixstowe', mode_of_transport: 'ocean', transshipment: 'ZACPT'),
        create(:itinerary, tenant: tenant, name: 'Shanghai - Felixstowe', mode_of_transport: 'air')
      ]
    end

    context 'with base pricing' do
      before do
        ([itinerary] | multi_mot_itineraries).each do |it|
          create(:lcl_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_1)
          create(:fcl_20_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_2)
          create(:fcl_40_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_2)
          create(:fcl_40_hq_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_2)
        end
      end

      it 'creates the trips for the correct itineraries with base pricing' do
        stats = Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
          described_class.insert(tenant: tenant, data: data, options: {})
        end

        aggregate_failures do
          expect(stats.dig(:trips, :number_created)).to eq(60)
          expect(itinerary.trips.where(load_type: 'cargo_item').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_1.id])
          expect(itinerary.trips.where(load_type: 'container').pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_2.id])
          expect(itinerary.trips.pluck(:start_date).map { |d| d.strftime('%^A') }.uniq).to eq(['THURSDAY'])
          expect(ignored_itinerary.trips).to be_empty
          expect(ignored_itinerary.trips).to be_empty
          expect(multi_mot_itineraries.map { |it| it.trips.count }.sum).to be_positive
        end
      end
    end
  end
end
