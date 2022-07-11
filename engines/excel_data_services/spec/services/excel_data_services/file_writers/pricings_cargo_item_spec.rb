# frozen_string_literal: true

require "rails_helper"
require "roo"

RSpec.describe ExcelDataServices::FileWriters::Pricings do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:group) { FactoryBot.create(:groups_group, organization: organization, name: "TEST") }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:static_pricing_headers) do
    described_class::HEADER_COLLECTION::PRICING_DYNAMIC_FEE_COLS_NO_RANGES.keys
      .map { |header| header.to_s.upcase }
  end
  let!(:transit_time) { FactoryBot.create(:legacy_transit_time, itinerary: itinerary, tenant_vehicle: tenant_vehicle) }

  let(:dynamic_pricing_headers) do
    %w[
      BAS
    ]
  end
  let(:result) do
    described_class.write_document(
      organization: organization,
      user: user,
      file_name: "test.xlsx",
      options: options
    )
  end
  let(:options) { { mode_of_transport: "ocean" } }
  let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
  let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }
  let(:headers) { first_sheet.row(1) }
  let(:static_headers) { headers[0..-2] }
  let(:dynamic_headers) { headers.last(1) }

  describe ".perform" do
    shared_examples_for "LCL Pricing Writer" do
      it "writes all pricings to the sheet", :aggregate_failures do
        expect(static_headers).to eq(static_pricing_headers)
        expect(dynamic_headers).to eq(dynamic_pricing_headers)
        expect(first_sheet.row(2)).to eq(pricing_row)
      end
    end

    before { pricing_row }

    context "when all pricings are valid" do
      let(:pricing_row) do
        [
          default_group.id,
          default_group.name,
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
          "LCL",
          "PER_WM",
          nil,
          transit_time.duration,
          nil,
          pricing.fees.first.cbm_ratio,
          pricing.fees.first.vm_ratio,
          "EUR",
          25
        ]
      end

      let(:pricing) do
        FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary,
                                        tenant_vehicle: tenant_vehicle)
      end

      it_behaves_like "LCL Pricing Writer"
    end

    context "when some pricings are expired" do
      before do
        FactoryBot.create(:lcl_pricing,
          organization: organization, itinerary: itinerary, tenant_vehicle: tenant_vehicle,
          expiration_date: Time.zone.now - 10.days, effective_date: Time.zone.now - 30.days)
      end

      let(:pricing_row) do
        [
          default_group.id,
          default_group.name,
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
          "LCL",
          "PER_WM",
          nil,
          transit_time.duration,
          nil,
          pricing.fees.first.cbm_ratio,
          pricing.fees.first.vm_ratio,
          "EUR",
          25
        ]
      end
      let(:pricing) do
        FactoryBot.create(:lcl_pricing, organization: organization, itinerary: itinerary,
                                        tenant_vehicle: tenant_vehicle)
      end

      it_behaves_like "LCL Pricing Writer"
    end

    context "when all pricings are valid with attached group" do
      let(:static_pricing_headers) do
        described_class::HEADER_COLLECTION::PRICING_ONE_FEE_COL_AND_RANGES.keys.map { |header| header.to_s.upcase }
      end
      let(:dynamic_pricing_headers) { ["RANGE_MAX"] }
      let(:pricing) do
        FactoryBot.create(:pricings_pricing,
          organization: organization,
          group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          itinerary: itinerary,
          transshipment: "ZACPT",
          fees: [FactoryBot.build(:pricings_fee,
            range: [
              { min: 0.0, max: 4.9, rate: 8 },
              { min: 5.0, max: 10, rate: 12 }
            ],
            rate_basis: FactoryBot.create(:per_wm_rate_basis),
            rate: 25,
            charge_category: FactoryBot.create(:bas_charge, organization: organization))])
      end
      let(:pricing_row) do
        [
          group.id,
          group.name,
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
          "LCL",
          "PER_WM",
          pricing.transshipment,
          transit_time.duration,
          nil,
          pricing.fees.first.cbm_ratio,
          pricing.fees.first.vm_ratio,
          "BAS",
          "Basic Ocean Freight",
          "EUR",
          1,
          8,
          0,
          4.9
        ]
      end
      let(:options) { { mode_of_transport: "ocean", group_id: group.id } }
      let(:static_headers) { headers }

      it_behaves_like "LCL Pricing Writer"
    end
  end
end
