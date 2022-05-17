# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: { hub_id: hamburg.id }) }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let(:country) { factory_country_from_code(code: "DE") }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Gateway Cargo GmbH", code: "gateway cargo gmbh") }
  let!(:standard_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
  let!(:faster_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "Faster", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
  let(:result_stats) { service.perform }
  let(:zone_1_standard_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: standard_tenant_vehicle) }
  let(:zone_1_faster_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: faster_tenant_vehicle) }
  let(:zone_2_faster_trucking) { Trucking::Trucking.find_by(location: zone_2_trucking_location, tenant_vehicle: faster_tenant_vehicle) }

  before do
    Timecop.freeze(Date.parse("2020/01/01"))
    Organizations.current_id = organization.id
    zone_1_trucking_location
    zone_2_trucking_location
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
  end

  after { Timecop.return }

  describe "#perform" do
    context "with location based numeric postal codes" do
      let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }
      let(:zone_1_trucking_location) do
        FactoryBot.create(:trucking_location,
          :location,
          data: "01067",
          location: FactoryBot.create(:locations_location, name: "01067", country_code: country.code.downcase),
          country: country)
      end
      let(:zone_2_trucking_location) do
        FactoryBot.create(:trucking_location,
          :location,
          data: "20457",
          location: FactoryBot.create(:locations_location, name: "20457", country_code: country.code.downcase),
          country: country)
      end

      it "returns stats indicating the success of the Upload", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(Trucking::Trucking.count).to eq(3)
      end

      it "assigns the FSC fee to all truckings", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(zone_1_standard_trucking.fees.keys).to include("FSC")
        expect(zone_2_faster_trucking.fees.keys).to include("FSC")
        expect(zone_1_faster_trucking.fees.keys).to include("FSC")
      end

      it "assigns PUF fees to zone 1 truckings", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(zone_1_standard_trucking.fees.keys).to include("PUF")
        expect(zone_1_faster_trucking.fees.keys).to include("PUF")
      end

      it "assigns THC fees to faster service truckings", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(zone_2_faster_trucking.fees.keys).to include("THC")
        expect(zone_1_faster_trucking.fees.keys).to include("THC")
      end
    end

    context "with location based alphanumeric postal codes" do
      let(:xlsx) { File.open(file_fixture("excel/example_alphanumeric_trucking.xlsx")) }
      let(:country) { factory_country_from_code(code: "GB") }
      let(:zone_1_trucking_location) do
        FactoryBot.create(:trucking_location,
          :location,
          data: "SR8",
          location: FactoryBot.create(:locations_location, name: "SR8", country_code: country.code.downcase),
          country: country)
      end
      let(:zone_2_trucking_location) do
        FactoryBot.create(:trucking_location,
          :location,
          data: "WC",
          location: FactoryBot.create(:locations_location, name: "WC", country_code: country.code.downcase),
          country: country)
      end

      it "returns stats indicating the success of the Upload", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(zone_1_standard_trucking).to be_present
        expect(zone_1_faster_trucking).to be_present
        expect(zone_2_faster_trucking).to be_present
      end
    end

    context "with distance based truckings" do
      let(:carrier) { FactoryBot.create(:legacy_carrier, name: "ORGANIZATION_SLUG", code: "ORGANIZATION_SLUG") } # temp till next pr comes through
      let(:xlsx) { File.open(file_fixture("excel/example_distance_trucking.xlsx")) }
      let(:zone_1_trucking_location) do
        FactoryBot.create(:trucking_location,
          :distance,
          data: "2",
          country: country)
      end
      let(:zone_2_trucking_location) do
        FactoryBot.create(:trucking_location,
          :distance,
          data: "1001",
          country: country)
      end

      it "returns stats indicating the success of the Upload", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(zone_1_standard_trucking).to be_present
        expect(zone_1_faster_trucking).to be_present
        expect(zone_2_faster_trucking).to be_present
      end
    end
  end
end
