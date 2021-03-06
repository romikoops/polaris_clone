# frozen_string_literal: true

require "rails_helper"
require "roo"

RSpec.describe ExcelDataServices::FileWriters::LocalCharges do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let!(:hub) do
    FactoryBot.create(:gothenburg_hub,
      free_out: false,
      organization: organization,
      mandatory_charge: FactoryBot.create(:legacy_mandatory_charge),
      nexus: FactoryBot.create(:gothenburg_nexus))
  end
  let(:result) do
    described_class.write_document(organization: organization, user: user, file_name: "test.xlsx", options: {})
  end
  let(:xlsx) { Roo::Excelx.new(StringIO.new(result.file.download)) }
  let(:first_sheet) { xlsx.sheet(xlsx.sheets.first) }

  context "when valid" do
    let!(:local_charge) { FactoryBot.create(:legacy_local_charge, hub: hub, organization: organization, group_id: group.id) }
    let(:local_charge_data_without_ranges) do
      { "GROUP_ID" => local_charge.group_id,
        "GROUP_NAME" => Groups::Group.find_by(id: local_charge.group_id)&.name,
        "EFFECTIVE_DATE" => local_charge.effective_date.strftime("%F"),
        "EXPIRATION_DATE" => local_charge.expiration_date.strftime("%F"),
        "LOCODE" => hub.nexus.locode,
        "HUB" => hub.name,
        "COUNTRY" => hub.country.name,
        "COUNTERPART_LOCODE" => nil,
        "COUNTERPART_HUB" => nil,
        "COUNTERPART_COUNTRY" => nil,
        "SERVICE_LEVEL" => "standard",
        "CARRIER" => local_charge.tenant_vehicle.carrier.name,
        "FEE_CODE" => "SOLAS",
        "FEE" => "SOLAS",
        "MOT" => "ocean",
        "LOAD_TYPE" => "lcl",
        "DIRECTION" => "export",
        "CURRENCY" => "EUR",
        "RATE_BASIS" => "PER_SHIPMENT",
        "MINIMUM" => 17.5,
        "MAXIMUM" => nil,
        "BASE" => nil,
        "TON" => nil,
        "CBM" => nil,
        "KG" => nil,
        "ITEM" => nil,
        "SHIPMENT" => 17.5,
        "BILL" => nil,
        "CONTAINER" => nil,
        "WM" => nil,
        "RANGE_MIN" => nil,
        "RANGE_MAX" => nil,
        "DANGEROUS" => nil }
    end

    context "without ranges" do
      let(:group) { default_group }

      describe ".perform" do
        it "writes all local charges to the sheet", :aggregate_failures do
          expect(first_sheet.row(1)).to eq(local_charge_data_without_ranges.keys)
          expect(first_sheet.row(2)).to eq(local_charge_data_without_ranges.values)
        end
      end
    end

    context "with attached group" do
      let(:group) { FactoryBot.create(:groups_group, organization: organization, name: "TEST") }

      describe ".perform" do
        it "writes all local charges to the sheet", :aggregate_failures do
          expect(first_sheet.row(1)).to eq(local_charge_data_without_ranges.keys)
          expect(first_sheet.row(2)).to eq(local_charge_data_without_ranges.values)
        end
      end
    end

    context "with ranges" do
      let!(:local_charge) { FactoryBot.create(:legacy_local_charge, :range, hub: hub, organization: organization) }

      let(:local_charge_data_with_ranges_base) do
        {
          "GROUP_ID" => default_group.id,
          "GROUP_NAME" => default_group.name,
          "EFFECTIVE_DATE" => local_charge.effective_date.strftime("%F"),
          "EXPIRATION_DATE" => local_charge.expiration_date.strftime("%F"),
          "LOCODE" => hub.nexus.locode,
          "HUB" => hub.name,
          "COUNTRY" => hub.country.name,
          "COUNTERPART_LOCODE" => nil,
          "COUNTERPART_HUB" => nil,
          "COUNTERPART_COUNTRY" => nil,
          "SERVICE_LEVEL" => "standard",
          "CARRIER" => local_charge.tenant_vehicle.carrier.name,
          "FEE_CODE" => "QDF",
          "FEE" => "Wharfage / Quay Dues",
          "MOT" => "ocean",
          "LOAD_TYPE" => "lcl",
          "DIRECTION" => "export",
          "CURRENCY" => "EUR",
          "RATE_BASIS" => "PER_UNIT_TON_CBM_RANGE",
          "MINIMUM" => 57,
          "MAXIMUM" => nil,
          "BASE" => nil,
          "KG" => nil,
          "ITEM" => nil,
          "SHIPMENT" => nil,
          "BILL" => nil,
          "CONTAINER" => nil,
          "WM" => nil,
          "DANGEROUS" => nil
        }
      end

      let(:local_charge_data_with_ranges) do
        [{ "TON" => 41,
           "CBM" => nil,
           "RANGE_MIN" => 0,
           "RANGE_MAX" => 5 },
          { "TON" => nil,
            "CBM" => 8.0,
            "RANGE_MIN" => 6,
            "RANGE_MAX" => 40 }].map { |range| local_charge_data_with_ranges_base.merge(range) }
      end

      describe ".perform" do
        it "writes all local charges to the sheet", :aggregate_failures do
          expect(first_sheet.row(1)).to match_array(local_charge_data_with_ranges.first.keys)
          expect(first_sheet.row(2)).to match_array(local_charge_data_with_ranges.first.values)
          expect(first_sheet.row(3)).to match_array(local_charge_data_with_ranges.second.values)
        end
      end
    end

    context "with base" do
      let!(:local_charge) { FactoryBot.create(:legacy_local_charge, :fees_with_base, hub: hub, organization: organization) }
      let(:local_charge_data_with_base) do
        { "GROUP_ID" => default_group.id,
          "GROUP_NAME" => default_group.name,
          "EFFECTIVE_DATE" => local_charge.effective_date.strftime("%F"),
          "EXPIRATION_DATE" => local_charge.expiration_date.strftime("%F"),
          "LOCODE" => hub.nexus.locode,
          "HUB" => hub.name,
          "COUNTRY" => hub.country.name,
          "COUNTERPART_LOCODE" => nil,
          "COUNTERPART_HUB" => nil,
          "COUNTERPART_COUNTRY" => nil,
          "SERVICE_LEVEL" => "standard",
          "CARRIER" => local_charge.tenant_vehicle.carrier.name,
          "FEE_CODE" => "THC",
          "FEE" => local_charge.fees.dig("THC", "name"),
          "MOT" => "ocean",
          "LOAD_TYPE" => "lcl",
          "DIRECTION" => "export",
          "CURRENCY" => "EUR",
          "RATE_BASIS" => "PER_X_KG",
          "MINIMUM" => local_charge.fees.dig("THC", "min"),
          "MAXIMUM" => nil,
          "BASE" => local_charge.fees.dig("THC", "base"),
          "TON" => nil,
          "CBM" => nil,
          "KG" => local_charge.fees.dig("THC", "value"),
          "ITEM" => nil,
          "SHIPMENT" => nil,
          "BILL" => nil,
          "CONTAINER" => nil,
          "WM" => nil,
          "RANGE_MIN" => nil,
          "RANGE_MAX" => nil,
          "DANGEROUS" => nil }
      end

      describe ".perform" do
        it "writes all local charges to the sheet", :aggregate_failures do
          expect(first_sheet.row(1)).to eq(local_charge_data_with_base.keys)
          expect(first_sheet.row(2)).to eq(local_charge_data_with_base.values)
        end
      end
    end
  end
end
