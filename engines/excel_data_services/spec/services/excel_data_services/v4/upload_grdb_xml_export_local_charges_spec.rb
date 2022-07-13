# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:tenant_vehicle) { Legacy::TenantVehicle.joins(:carrier).find_by(name: "standard", carriers: { name: "WWA", code: "wwa" }, organization: organization) }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let!(:shanghai) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
  let!(:ningbo) { FactoryBot.create(:legacy_hub, name: "Ningbo", hub_code: "CNNBG", organization: organization, nexus: FactoryBot.create(:legacy_nexus, name: "Ningbo", locode: "CNNBG", organization: organization)) }
  let(:local_charges) { Legacy::LocalCharge.where(organization: organization, tenant_vehicle: tenant_vehicle, load_type: "lcl", direction: "export", hub: hamburg) }
  let(:xlsx) { File.open(file_fixture("xml/example_grdb_origin_charges.xml")) }
  let!(:file) do
    FactoryBot.create(:legacy_file).tap do |file_object|
      file_object.file.attach(io: xlsx, filename: "test-sheet.xml", content_type: "application/xml")
    end
  end

  Timecop.freeze(Time.zone.local(2022, 1, 1, 12, 0, 0)) do
    describe "#perform" do
      let(:result_stats) { service.perform }
      let(:hamburg_to_shanghai_local_charge) { local_charges.find_by(counterpart_hub: shanghai) }
      let(:hamburg_to_ningbo_local_charge) { local_charges.find_by(counterpart_hub: ningbo) }

      before do
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_WM")
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_CONTAINER")
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_TON")
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_SHIPMENT")
        result_stats
      end

      it "creates a new local charge for each of the destinations provided", :aggregate_failures do
        expect(hamburg_to_shanghai_local_charge).to be_present
        expect(hamburg_to_ningbo_local_charge).to be_present
      end

      expected_hamburg_shanghai_codes = %w[CHA CHC DEN FAC INF SEC WAC WRH BLSC CGSF HNDF ISPS]
      expected_hamburg_ningbo_codes = %w[CHA CHP DEN FAC INF SEC WAC WRH BLSC CGSF HNDF ISPS]

      it "adds the correct fees to each LocalCharge", :aggregate_failures do
        expect(hamburg_to_shanghai_local_charge.fees.keys).to match_array(expected_hamburg_shanghai_codes)
        expect(hamburg_to_ningbo_local_charge.fees.keys).to match_array(expected_hamburg_ningbo_codes)
      end

      expected_validities = [
        Range.new(Date.parse("Sun, 01 Nov 2020"), Date.parse("Fri, 22 Oct 2021")),
        Range.new(Date.parse("Fri, 22 Oct 2021"), Date.parse("Fri, 19 Nov 2021")),
        Range.new(Date.parse("Fri, 19 Nov 2021"), Date.parse("Sun, 13 Mar 2022")),
        Range.new(Date.parse("Sun, 13 Mar 2022"), Date.parse("Fri, 01 Jul 2022"))
      ]
      it "splits up the fees into multiple LocalCharges based on the validity periods" do
        expect(local_charges.pluck(:validity).uniq).to match_array(expected_validities)
      end
    end

    describe "#valid?" do
      let(:xlsx) { File.open(file_fixture("xml/example_grdb_origin_charges.xml")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
