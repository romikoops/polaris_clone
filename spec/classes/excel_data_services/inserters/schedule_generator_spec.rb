# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExcelDataServices::Inserters::ScheduleGenerator do
  describe '.perform' do
    let(:data) { FactoryBot.build(:excel_data_restructured_schedule_generator) }
    let(:organization) { create(:organizations_organization) }
    let(:vehicle) { create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
    let(:carrier) { create(:carrier, code: 'hapag lloyd', name: 'Hapag LLoyd') }
    let(:tenant_vehicle_1) { create(:tenant_vehicle, name: 'lcl_service', organization: organization) }
    let(:tenant_vehicle_2) { create(:tenant_vehicle, name: 'fcl_service', organization: organization, carrier: carrier) }
    let!(:itinerary) { create(:itinerary, organization: organization, name: 'Dalian - Felixstowe') }
    let!(:ignored_itinerary) { create(:itinerary, organization: organization, name: 'Dalian - Felixstowe', mode_of_transport: 'rail') }
    let!(:misspelled_itinerary) { create(:itinerary, organization: organization, name: 'Sahnghai - Felixstowe', mode_of_transport: 'air') }
    let!(:multi_mot_itineraries) do
      [
        create(:itinerary, organization: organization, name: 'Shanghai - Felixstowe', mode_of_transport: 'ocean'),
        create(:itinerary, organization: organization, name: 'Shanghai - Felixstowe', mode_of_transport: 'ocean', transshipment: 'ZACPT'),
        create(:itinerary, organization: organization, name: 'Shanghai - Felixstowe', mode_of_transport: 'air')
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
          described_class.insert(organization: organization, data: data, options: {})
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
