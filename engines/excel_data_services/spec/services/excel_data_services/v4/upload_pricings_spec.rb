# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:tenant_vehicle) { Legacy::TenantVehicle.joins(:carrier).find_by(name: "standard", carriers: { name: "MSC", code: "msc" }, organization: organization) }
  let!(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, organization: organization) }
  let!(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
  let!(:test_group) { FactoryBot.create(:groups_group, id: "1b536235-4bd4-49a7-874e-489ce9e2d251", organization: organization, name: "TEST_GROUP") }
  let(:fees) { Pricings::Fee.joins(:charge_category).joins(pricing: :itinerary) }

  describe "#perform" do
    let(:result_stats) { service.perform }
    let(:lcl_fee) do
      fees.find_by(
        charge_categories: { code: "imo 2020" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "lcl", group_id: test_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: nil },
        organization: organization
      )
    end

    let(:lcl_range_fee) do
      fees.find_by(
        charge_categories: { code: "baf" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "lcl", group_id: test_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: nil },
        organization: organization
      )
    end

    let(:fcl_40_fee) do
      fees.find_by(
        charge_categories: { code: "ofr" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "fcl_40", group_id: default_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: nil },
        organization: organization
      )
    end

    let(:fcl_40_hq_fee) do
      fees.find_by(
        charge_categories: { code: "ofr" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "fcl_40_hq", group_id: default_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: nil },
        organization: organization
      )
    end

    let(:transhipment_lcl_fee) do
      fees.find_by(
        charge_categories: { code: "bas" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "lcl", group_id: test_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: "ZACPT" },
        organization: organization
      )
    end

    let(:transhipment_fcl_20_ofr_fee) do
      fees.find_by(
        charge_categories: { code: "ofr" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "fcl_20", group_id: default_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: "ZACPT" },
        organization: organization
      )
    end

    let(:transhipment_fcl_20_lss_fee) do
      fees.find_by(
        charge_categories: { code: "lss" },
        pricings_pricings: { tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "fcl_20", group_id: default_group.id },
        itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: "ZACPT" },
        organization: organization
      )
    end

    before do
      FactoryBot.create(:pricings_rate_basis, external_code: "PER_WM")
      FactoryBot.create(:pricings_rate_basis, external_code: "PER_CONTAINER")
    end

    context "when dynamic and fcl and range based formats are together in the same sheet" do
      before { service.perform }

      it "returns inserts the lcl fees ", :aggregate_failures do
        expect(lcl_fee.rate).to eq(40)
        expect(lcl_range_fee.range).to match_array([{ "max" => 100.0, "min" => 0.0, "rate" => 210.0 }, { "max" => 500.0, "min" => 100.0, "rate" => 110.0 }])
        expect(transhipment_lcl_fee.rate).to eq(210)
      end

      it "returns a dynamic fcl fees", :aggregate_failures do
        expect(fcl_40_fee.rate).to eq(4660)
        expect(fcl_40_hq_fee.rate).to eq(5330)
        expect(transhipment_fcl_20_ofr_fee.rate).to eq(4330)
        expect(transhipment_fcl_20_lss_fee.rate).to eq(200)
      end

      it "creates a TransitTime when one is specified" do
        transit_time = Legacy::TransitTime.joins(:itinerary).find_by(tenant_vehicle: tenant_vehicle, itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: "ZACPT" })
        expect(transit_time.duration).to eq(35)
      end
    end

    context "when the TransitTime already exists" do
      let!(:itinerary) { FactoryBot.create(:legacy_itinerary, origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: "ZACPT", organization: organization) }
      let!(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: FactoryBot.create(:legacy_carrier, name: "MSC", code: "msc"), organization: organization, mode_of_transport: "ocean") }
      let!(:transit_time) { FactoryBot.create(:legacy_transit_time, itinerary: itinerary, tenant_vehicle: tenant_vehicle, duration: 5) }

      before { service.perform }

      it "updates the existing TransitTime when one is specified" do
        expect(transit_time.reload.duration).to eq(35)
      end
    end

    context "with only dynamic formats in one upload" do
      let(:xlsx) { File.open(file_fixture("excel/example_pricings_dynamic.xlsx")) }

      before { service.perform }

      it "returns a dynamic fcl fees", :aggregate_failures do
        expect(fcl_40_fee.rate).to eq(4660)
        expect(fcl_40_hq_fee.rate).to eq(5330)
        expect(transhipment_fcl_20_ofr_fee.rate).to eq(4330)
        expect(transhipment_fcl_20_lss_fee.rate).to eq(200)
      end
    end
  end

  describe "#valid?" do
    context "with an empty sheet" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "with an hubs sheet" do
      let(:xlsx) { File.open(file_fixture("excel/example_hubs.xlsx")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
