# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::ScheduleGenerator do
  describe ".perform" do
    let(:data) { FactoryBot.build(:excel_data_restructured_schedule_generator) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle_1]) }
    let(:carrier) { FactoryBot.create(:legacy_carrier, code: "hapag lloyd", name: "Hapag LLoyd") }
    let(:tenant_vehicle_1) do
      FactoryBot.create(:legacy_tenant_vehicle, name: "lcl_service", organization: organization)
    end
    let(:tenant_vehicle_2) do
      FactoryBot.create(:legacy_tenant_vehicle, name: "fcl_service", organization: organization, carrier: carrier)
    end
    let!(:itinerary) { FactoryBot.create(:default_itinerary, organization: organization, name: "Dalian - Felixstowe") }
    let!(:ignored_itinerary) do
      FactoryBot.create(:default_itinerary, organization: organization, name: "Dalian - Felixstowe",
                                            mode_of_transport: "rail")
    end
    let!(:misspelled_itinerary) do
      FactoryBot.create(:default_itinerary, organization: organization, name: "Sahnghai - Felixstowe",
                                            mode_of_transport: "air")
    end
    let!(:multi_mot_itineraries) do
      [
        FactoryBot.create(:default_itinerary,
          organization: organization, name: "Shanghai - Felixstowe", mode_of_transport: "ocean"),
        FactoryBot.create(:default_itinerary,
          organization: organization, name: "Shanghai - Felixstowe", mode_of_transport: "ocean",
          transshipment: "ZACPT"),
        FactoryBot.create(:default_itinerary,
          organization: organization, name: "Shanghai - Felixstowe", mode_of_transport: "air")
      ]
    end

    context "with base pricing" do
      before do
        ([itinerary] | multi_mot_itineraries).each do |it|
          FactoryBot.create(:lcl_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_1)
          FactoryBot.create(:fcl_20_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_2)
          FactoryBot.create(:fcl_40_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_2)
          FactoryBot.create(:fcl_40_hq_pricing, itinerary: it, tenant_vehicle: tenant_vehicle_2)
        end
      end

      it "creates the trips for the correct itineraries with base pricing" do
        stats = Timecop.freeze(Time.utc(2019, 2, 22, 11, 54, 0)) do
          described_class.insert(organization: organization, data: data, options: {})
        end

        aggregate_failures do
          expect(stats.dig(:"legacy/trips", :number_created)).to eq(60)
          expect(
            itinerary.trips.where(load_type: "cargo_item").pluck(:tenant_vehicle_id).uniq
          ).to eq([tenant_vehicle_1.id])
          expect(
            itinerary.trips.where(load_type: "container").pluck(:tenant_vehicle_id).uniq
          ).to eq([tenant_vehicle_2.id])
          expect(
            itinerary.trips.pluck(:start_date).map { |d| d.strftime("%^A") }.uniq
          ).to eq(["THURSDAY"])
          expect(ignored_itinerary.trips).to be_empty
          expect(ignored_itinerary.trips).to be_empty
          expect(multi_mot_itineraries.map { |it| it.trips.count }.sum).to be_positive
        end
      end
    end
  end
end
