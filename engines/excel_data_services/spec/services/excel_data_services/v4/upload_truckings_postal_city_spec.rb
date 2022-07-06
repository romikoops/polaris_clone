# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: { hub_id: hamburg.id }) }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let(:country) { factory_country_from_code(code: "DE") }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "IGS", code: "igs") }
  let(:result_stats) { service.perform }
  let(:fcl_20_postal_truckings) { Trucking::Trucking.where(cargo_class: "fcl_20", location: [postal_trucking_location_a, postal_trucking_location_b]) }
  let(:fcl_40_postal_truckings) { Trucking::Trucking.where(cargo_class: "fcl_20", location: [postal_trucking_location_a, postal_trucking_location_b]) }
  let(:fcl_20_city_truckings) { Trucking::Trucking.where(cargo_class: "fcl_40", location: [city_trucking_location_a, city_trucking_location_b]) }
  let(:fcl_40_city_truckings) { Trucking::Trucking.where(cargo_class: "fcl_40", location: [city_trucking_location_a, city_trucking_location_b]) }
  let(:horka) { FactoryBot.create(:locations_location, :in_sweden, osm_id: nil, name: "Horka", admin_level: 8, country_code: country.code.downcase) }
  let(:kodersdorf) { FactoryBot.create(:locations_location, :in_sweden, osm_id: nil, name: "Kodersdorf", admin_level: 8, country_code: country.code.downcase) }

  before do
    Timecop.freeze(Date.parse("2020/01/01"))
    Organizations.current_id = organization.id
    FactoryBot.create(:legacy_tenant_vehicle, name: "DRESDEN (Riesa)", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage")
    %w[
      PER_TON
      PER_CBM
      PER_KG
      PER_ITEM
      PER_SHIPMENT
      PER_BILL
      PER_CONTAINER
      PER_WM
      PERCENTAGE
      PER_KG_RANGE
      PER_X_KG
    ].each { |rate_basis| FactoryBot.create(:pricings_rate_basis, external_code: rate_basis) }
    FactoryBot.create(:locations_location, name: "01097", admin_level: nil, country_code: country.code.downcase)
    FactoryBot.create(:locations_location, name: "01098", admin_level: nil, country_code: country.code.downcase)
    FactoryBot.create(:locations_location, name: "01099", admin_level: nil, country_code: country.code.downcase)
    FactoryBot.create(:locations_location, :in_sweden_large, name: "02923", admin_level: nil, country_code: country.code.downcase)
    Locations::Name.searchkick_index.create if Locations::Name.searchkick_index.blank?
    FactoryBot.create(:locations_name,
      :reindex,
      name: horka.name,
      city: horka.name,
      postal_code: nil,
      country_code: country.code,
      location: horka,
      point: horka.bounds.centroid)
    FactoryBot.create(:locations_name,
      :reindex,
      name: kodersdorf.name,
      city: kodersdorf.name,
      postal_code: nil,
      country_code: country.code,
      location: kodersdorf,
      point: kodersdorf.bounds.centroid)
    Locations::Name.reindex
  end

  after do
    Locations::Name.searchkick_index.delete if Locations::Name.searchkick_index.present?
    Timecop.return
  end

  describe "#perform" do
    context "with location based numeric postal codes" do
      let(:xlsx) { File.open(file_fixture("excel/example_postal_city_trucking.xlsx")) }
      let(:postal_trucking_location_a) do
        Trucking::Location.joins(:location).find_by(
          data: "01097",
          country: country,
          locations_locations: { name: "01097", country_code: country.code.downcase }
        )
      end
      let(:postal_trucking_location_b) do
        Trucking::Location.joins(:location).find_by(
          data: "01099",
          country: country,
          locations_locations: { name: "01099", country_code: country.code.downcase }
        )
      end
      let(:city_trucking_location_a) do
        Trucking::Location.joins(:location).find_by(
          data: "Horka",
          country: country,
          locations_locations: { name: "Horka", country_code: country.code.downcase }
        )
      end
      let(:city_trucking_location_b) do
        Trucking::Location.joins(:location).find_by(
          data: "Kodersdorf",
          country: country,
          locations_locations: { name: "Kodersdorf", country_code: country.code.downcase }
        )
      end

      it "returns stats indicating the success of the Upload", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(Trucking::Trucking.count).to eq(8)
      end

      it "assigns truckings to the postal code rows", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(fcl_20_postal_truckings.count).to eq(2)
        expect(fcl_40_postal_truckings.count).to eq(2)
      end

      it "assigns truckings to the city rows", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(fcl_20_city_truckings.count).to eq(2)
        expect(fcl_40_city_truckings.count).to eq(2)
      end
    end
  end
end
