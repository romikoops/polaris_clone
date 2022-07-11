# frozen_string_literal: true

require "rails_helper"
require "roo"

RSpec.describe ExcelDataServices::FileWriters::Pricings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:static_pricing_headers) do
    described_class::HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES.keys
      .map { |header| header.to_s.upcase }
  end
  let(:group) { FactoryBot.create(:groups_group, organization: organization, name: "TEST") }
  let!(:transit_time) { FactoryBot.create(:legacy_transit_time, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }
  let(:options) { { mode_of_transport: "ocean" } }
  let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
  let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }
  let(:headers) { first_sheet.row(1) }
  let(:static_headers) { headers[0..-2] }
  let(:dynamic_headers) { headers.last(1) }
  let(:result) do
    described_class.write_document(
      organization: organization,
      user: user,
      file_name: "test.xlsx",
      options: options
    )
  end
  let(:dynamic_pricing_headers) do
    %w[
      BAS
    ]
  end
  let(:pricing_row) do
    [
      pricing.group_id,
      pricing.group.name,
      pricing.effective_date.to_date,
      pricing.expiration_date.to_date,
      itinerary.origin_hub.locode,
      "Gothenburg",
      "Sweden",
      itinerary.destination_hub.locode,
      "Shanghai",
      "China",
      "ocean",
      tenant_vehicle.carrier.name,
      "standard",
      "FCL_20",
      "PER_CONTAINER",
      pricing.transshipment,
      transit_time.duration,
      nil,
      pricing.fees.first.cbm_ratio,
      pricing.fees.first.vm_ratio,
      "EUR",
      250
    ]
  end

  before { pricing_row }

  describe ".perform" do
    shared_examples_for "FCL Pricing Writer" do
      it "writes all pricings to the sheet", :aggregate_failures do
        expect(static_headers).to eq(static_pricing_headers)
        expect(dynamic_headers).to eq(dynamic_pricing_headers)
        expect(first_sheet.row(2)).to eq(pricing_row)
      end
    end

    context "with standard fcl pricing" do
      let(:pricing) do
        FactoryBot.create(:fcl_20_pricing, organization: organization, group: default_group,
                                           itinerary: itinerary, tenant_vehicle: tenant_vehicle)
      end

      it_behaves_like "FCL Pricing Writer"
    end

    context "when all pricings are valid with attached group" do
      let(:pricing) do
        FactoryBot.create(:fcl_20_pricing,
          organization: organization, group: group, itinerary: itinerary,
          tenant_vehicle: tenant_vehicle)
      end
      let(:options) { { mode_of_transport: "ocean", group_id: group.id } }

      it_behaves_like "FCL Pricing Writer"
    end
  end
end
