# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Schedules do
  describe ".perform" do
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: "MSC", code: "msc") }
    let(:data) { FactoryBot.build(:excel_data_restructured_schedules) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let!(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier_id: nil, organization: organization) }
    let!(:tenant_vehicle_2) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization) }
    let!(:tenant_vehicle_3) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier_id: nil, organization: organization, mode_of_transport: "air") }

    let!(:itinerary) { FactoryBot.create(:default_itinerary, organization: organization, name: "Dalian - Felixstowe") }
    let!(:transshipment_itinerary) { FactoryBot.create(:default_itinerary, organization: organization, name: "Dalian - Felixstowe", transshipment: "ZACPT") }
    let!(:air_itinerary) { FactoryBot.create(:default_itinerary, organization: organization, name: "Dalian - Felixstowe", mode_of_transport: "air") }

    context "when uploading a schedules sheet" do
      let!(:stats) do
        Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
          described_class.insert(organization: organization, data: data, options: {})
        end
      end

      it "creates correct stats" do
        aggregate_failures do
          expect(stats.dig(:"legacy/trips", :number_created)).to eq(4)
        end
      end

      it "creates the trips for the correct itineraries" do
        aggregate_failures do
          expect(air_itinerary.trips.where(load_type: "cargo_item").pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_3.id])
          expect(itinerary.trips.where(load_type: "cargo_item").pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_1.id])
          expect(transshipment_itinerary.trips.where(load_type: "container").pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_2.id])
          expect(itinerary.trips.where(load_type: "container").pluck(:tenant_vehicle_id).uniq).to eq([tenant_vehicle_2.id])
          expect(itinerary.trips.pluck(:closing_date).compact).to be_present
          expect(itinerary.trips.pluck(:start_date).compact).to be_present
          expect(itinerary.trips.pluck(:end_date).compact).to be_present
        end
      end

      it "creates the trips with all date values" do
        aggregate_failures do
          expect(itinerary.trips.pluck(:closing_date).compact).to be_present
          expect(itinerary.trips.pluck(:start_date).compact).to be_present
          expect(itinerary.trips.pluck(:end_date).compact).to be_present
        end
      end

      it "creates the layovers with all date values" do
        layovers = Legacy::Layover.where(trip_id: itinerary.trips.ids)
        aggregate_failures do
          expect(layovers.pluck(:closing_date).compact).to be_present
          expect(layovers.pluck(:etd).compact).to be_present
          expect(layovers.pluck(:eta).compact).to be_present
          expect(layovers.pluck(:stop_index).compact).to be_present
        end
      end
    end
  end
end
