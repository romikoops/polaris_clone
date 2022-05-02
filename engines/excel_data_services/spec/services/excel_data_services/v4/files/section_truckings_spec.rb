# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Section do
  include_context "V4 setup"

  let(:xlsx) { File.open(file_fixture("excel/example_trucking.xlsx")) }
  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let(:overrides) { ExcelDataServices::V4::Overrides.new(hub_id: hamburg.id) }

  before do
    Timecop.freeze(Date.parse("2020/01/01"))
    Organizations.current_id = organization.id
  end

  after { Timecop.return }

  describe "#valid?" do
    let(:section_string) { "Truckings" }

    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#perform" do
    let(:section_string) { "Truckings" }
    let(:country) { factory_country_from_code(code: "DE") }
    let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Gateway Cargo GmbH", code: "gateway cargo gmbh") }
    let(:org_carrier) { FactoryBot.create(:legacy_carrier, name: organization.slug, code: organization.slug) }
    let!(:standard_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
    let!(:faster_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "Faster", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
    let!(:zone_1_trucking_location) do
      FactoryBot.create(:trucking_location,
        :location,
        data: "01067",
        location: FactoryBot.create(:locations_location, name: "01067", country_code: country.code.downcase),
        country: country)
    end
    let!(:zone_2_trucking_location) do
      FactoryBot.create(:trucking_location,
        :location,
        data: "20457",
        location: FactoryBot.create(:locations_location, name: "20457", country_code: country.code.downcase),
        country: country)
    end
    let(:result_state) { service.perform }

    let(:zone_1_standard_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: standard_tenant_vehicle) }
    let(:zone_1_faster_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: faster_tenant_vehicle) }
    let(:zone_2_faster_trucking) { Trucking::Trucking.find_by(location: zone_2_trucking_location, tenant_vehicle: faster_tenant_vehicle) }

    before do
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
      FactoryBot.create(:groups_group, organization: organization, name: "Local Charges Group One")
    end

    it "returns a State object after inserting Data", :aggregate_failures do
      expect(result_state).to be_a(ExcelDataServices::V4::State)
      expect(result_state.errors).to be_empty
      expect(Trucking::Trucking.count).to eq(3)
    end

    it "assigns the FSC fee to all truckings", :aggregate_failures do
      expect(result_state.errors).to be_empty
      expect(zone_1_standard_trucking.fees.keys).to include("FSC")
      expect(zone_2_faster_trucking.fees.keys).to include("FSC")
      expect(zone_1_faster_trucking.fees.keys).to include("FSC")
    end

    it "assigns PUF fees to zone 1 truckings", :aggregate_failures do
      expect(result_state.errors).to be_empty
      expect(zone_1_standard_trucking.fees.keys).to include("PUF")
      expect(zone_1_faster_trucking.fees.keys).to include("PUF")
    end

    it "assigns THC fees to faster service truckings", :aggregate_failures do
      expect(result_state.errors).to be_empty
      expect(zone_2_faster_trucking.fees.keys).to include("THC")
      expect(zone_1_faster_trucking.fees.keys).to include("THC")
    end
  end
end
