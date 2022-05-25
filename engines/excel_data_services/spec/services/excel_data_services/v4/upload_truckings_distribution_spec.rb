# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: { hub_id: hamburg.id, distribute: true }) }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let(:country) { factory_country_from_code(code: "DE") }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Gateway Cargo GmbH", code: "gateway cargo gmbh") }
  let!(:standard_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
  let!(:faster_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "Faster", carrier: carrier, organization: organization, mode_of_transport: "truck_carriage") }
  let!(:distributed_standard_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: distributee_org, mode_of_transport: "truck_carriage") }
  let!(:distributed_faster_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "Faster", carrier: carrier, organization: distributee_org, mode_of_transport: "truck_carriage") }
  let(:result_stats) { service.perform }
  let(:zone_1_standard_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: standard_tenant_vehicle, organization: organization) }
  let(:zone_1_faster_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: faster_tenant_vehicle, organization: organization) }
  let(:zone_2_faster_trucking) { Trucking::Trucking.find_by(location: zone_2_trucking_location, tenant_vehicle: faster_tenant_vehicle, organization: organization) }
  let(:distributed_zone_1_standard_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: distributed_standard_tenant_vehicle, organization: distributee_org) }
  let(:distributed_zone_1_faster_trucking) { Trucking::Trucking.find_by(location: zone_1_trucking_location, tenant_vehicle: distributed_faster_tenant_vehicle, organization: distributee_org) }
  let(:distributed_zone_2_faster_trucking) { Trucking::Trucking.find_by(location: zone_2_trucking_location, tenant_vehicle: distributed_faster_tenant_vehicle, organization: distributee_org) }
  let!(:distributee_org) { FactoryBot.create(:organizations_organization, slug: "distributed") }
  let!(:distributee_hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: distributee_org) }

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
    FactoryBot.create(:distributions_action, :duplicate,
      organization: organization,
      upload_schema: "trucking",
      target_organization: distributee_org,
      where: { hub_id: hamburg.id },
      order: 2)
    FactoryBot.create(:distributions_action, :add_values,
      organization: organization,
      upload_schema: "trucking",
      target_organization: distributee_org,
      order: 3,
      where: { hub_id: hamburg.id, fee_code: "trucking_lcl" },
      arguments: { hub_id: distributee_hamburg.id })
    FactoryBot.create(:distributions_action, :adjust_fee,
      organization: organization,
      upload_schema: "trucking",
      target_organization: distributee_org,
      order: 4,
      where: { hub_id: distributee_hamburg.id, fee_code: "trucking_lcl" },
      arguments: { operator: "%", value: 0.15 })
    FactoryBot.create(:groups_group, name: "default", organization: distributee_org)
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
        expect(Trucking::Trucking.count).to eq(6)
      end

      it "copies the Truckings to the distributee organization", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(distributed_zone_1_standard_trucking).to be_present
        expect(distributed_zone_2_faster_trucking).to be_present
        expect(distributed_zone_1_faster_trucking).to be_present
      end

      it "adjusts the distributed rates by the the set value", :aggregate_failures do
        expect(result_stats[:errors]).to be_empty
        expect(rates_from(trucking: distributed_zone_1_standard_trucking)).to eq(rates_from(trucking: zone_1_standard_trucking).map { |rate| rate * 1.15 })
        expect(rates_from(trucking: distributed_zone_2_faster_trucking)).to eq(rates_from(trucking: zone_2_faster_trucking).map { |rate| rate * 1.15 })
        expect(rates_from(trucking: distributed_zone_1_faster_trucking)).to eq(rates_from(trucking: zone_1_faster_trucking).map { |rate| rate * 1.15 })
      end
    end

    def rates_from(trucking:)
      trucking.rates["kg"].map { |rate_row| rate_row["rate"]["rate"].to_d }
    end
  end
end
