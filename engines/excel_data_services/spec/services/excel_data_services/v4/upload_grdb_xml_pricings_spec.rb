# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:tenant_vehicle) { Legacy::TenantVehicle.joins(:carrier).find_by(name: "standard", carriers: { name: "WWA", code: "wwa" }, organization: organization) }
  let!(:origin_hub) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let!(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
  let!(:ningbo_hub) { FactoryBot.create(:legacy_hub, name: "Ningbo", hub_code: "CNNBG", organization: organization, nexus: FactoryBot.create(:legacy_nexus, name: "Ningbo", locode: "CNNBG", organization: organization)) }
  let!(:dalian_hub) { FactoryBot.create(:legacy_hub, name: "Dalian", hub_code: "CNDAL", organization: organization, nexus: FactoryBot.create(:legacy_nexus, name: "Dalian", locode: "CNDAL", organization: organization)) }
  let(:pricings) { Pricings::Pricing.joins(fees: :charge_category).joins(:itinerary) }
  let(:xlsx) { File.open(file_fixture("xml/example_grdb.xml")) }
  let!(:file) do
    FactoryBot.create(:legacy_file).tap do |file_object|
      file_object.file.attach(io: xlsx, filename: "test-sheet.xml", content_type: "application/xml")
    end
  end

  Timecop.freeze(Time.zone.local(2022, 1, 1, 12, 0, 0)) do
    describe "#perform" do
      let(:result_stats) { service.perform }
      let(:shanghai_pricing) do
        pricings.find_by(
          tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "lcl",
          itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: destination_hub.id, transshipment: nil }
        )
      end

      let(:ningbo_pricing) do
        pricings.find_by(
          tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "lcl",
          itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: ningbo_hub.id }
        )
      end

      let(:dalian_pricing) do
        pricings.find_by(
          tenant_vehicle_id: tenant_vehicle.id, organization_id: organization.id, cargo_class: "lcl",
          itineraries: { origin_hub_id: origin_hub.id, destination_hub_id: dalian_hub.id }
        )
      end

      before do
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_WM")
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_CONTAINER")
        result_stats
      end

      it "returns inserts the lcl fees with the correct fee codes", :aggregate_failures do
        expect(shanghai_pricing.fees.joins(:charge_category).pluck("charge_categories.code")).to match_array(%w[ofr haz im20])
        expect(ningbo_pricing.fees.joins(:charge_category).pluck("charge_categories.code")).to match_array(%w[ofr haz im20])
      end

      it "returns inserts the lcl fees with the correct rates", :aggregate_failures do
        expect(shanghai_pricing.fees.pluck(:rate)).to match_array([40, 40, 4])
        expect(ningbo_pricing.fees.pluck(:rate)).to match_array([40, 40, 4])
        expect(dalian_pricing.fees.pluck(:rate)).to match_array([45])
      end

      it "returns inserts the lcl fees with the correct minimums", :aggregate_failures do
        expect(shanghai_pricing.fees.pluck(:min)).to match_array([40, 150, 4])
        expect(ningbo_pricing.fees.pluck(:min)).to match_array([40, 150, 4])
        expect(dalian_pricing.fees.pluck(:min)).to match_array([30])
      end
    end
  end
end
