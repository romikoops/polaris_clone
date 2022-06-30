# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: args) }
  let(:args) { {} }
  let(:section_string) { "GrdbExcel" }
  let(:xlsx) { File.open(file_fixture("excel/example_grdb.xlsx")) }
  let!(:distributee_org) { FactoryBot.create(:organizations_organization, slug: "distributed") }

  before do
    FactoryBot.create(:legacy_mandatory_charge)
  end

  describe "#perform" do
    Timecop.freeze(DateTime.parse("2021/08/31")) do
      let(:result_stats) { service.perform }

      before do
        %w[DEHAM BEANR DEBRV NLRTM JOAMM PTPDL DOPOP ZAPZB].each do |locode|
          FactoryBot.create(:legacy_hub, name: locode, hub_code: locode, nexus: FactoryBot.build(:legacy_nexus, name: locode, locode: locode, organization: organization), organization: organization)
          FactoryBot.create(:legacy_hub, name: locode, hub_code: locode, nexus: FactoryBot.build(:legacy_nexus, name: locode, locode: locode, organization: distributee_org), organization: distributee_org)
        end
        FactoryBot.create(:legacy_hub, name: "ATVIE", hub_code: "ATVIE", nexus: FactoryBot.build(:legacy_nexus, name: "ATVIE", locode: "ATVIE", organization: distributee_org), organization: distributee_org)
        FactoryBot.create(:groups_group, :default, organization: distributee_org)
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_WM")
        FactoryBot.create(:pricings_rate_basis, internal_code: "PER_SHIPMENT", external_code: "PER_B/L")
        FactoryBot.create(:pricings_rate_basis, internal_code: "PER_SHIPMENT", external_code: "PER_SHIPMENT")
        FactoryBot.create(:pricings_rate_basis, external_code: "PER_CONTAINER")
      end

      context "without distribution" do
        before { result_stats }

        it "returns a State object after inserting Data" do
          expect(result_stats).to eq({ carrier: { created: 2, failed: 0 }, charge_category: { created: 5, failed: 0 }, errors: [], itinerary: { created: 2, failed: 0 }, pricing: { created: 2, failed: 0 }, tenant_vehicle: { created: 1, failed: 0 } })
        end
      end

      context "with distributions" do
        before do
          FactoryBot.create(:distributions_action, :duplicate,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            where: { origin_locode: "DEHAM" },
            order: 1)
          FactoryBot.create(:distributions_action, :add_values,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            where: { origin_region: "EMEA" },
            order: 2,
            arguments: { origin_locode: "ATVIE", origin: "Wien Dry Port", dangerous: false })
          FactoryBot.create(:distributions_action, :add_fee,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            order: 3,
            where: { origin_locode: "ATVIE", fee_code: "ocean_freight" },
            arguments: { fee_code: "loading", fee_name: "Loading", currency: "EUR", rate: 25, rate_basis: "PER_WM" })
          FactoryBot.create(:distributions_action, :add_fee,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            order: 4,
            where: { origin_locode: "ATVIE", fee_code: "ocean_freight" },
            arguments: { fee_code: "transport vienna", fee_name: "Transport Vienna", currency: "EUR", rate: 30, minimum: 50, rate_basis: "PER_WM" })
          FactoryBot.create(:distributions_action, :add_fee,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            order: 5,
            where: { origin_locode: "ATVIE", fee_code: "ocean_freight" },
            arguments: { fee_code: "export customs", fee_name: "Export Customs", currency: "EUR", rate: 35, rate_basis: "PER_SHIPMENT" })
          FactoryBot.create(:distributions_action, :adjust_fee,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            order: 6,
            where: { origin_locode: "ATVIE", fee_code: "ocean_freight" },
            arguments: { operator: "%", value: 0.15 })
          FactoryBot.create(:distributions_action, :add_values,
            organization: organization,
            target_organization: distributee_org,
            upload_schema: "grdb_excel",
            order: 7,
            where: { origin_region: "EMEA" }, arguments: { group_name: "default" })
          result_stats
        end

        let(:args) { { distribute: true } }
        let(:distributed_ocean_freight) { Pricings::Fee.joins(:charge_category).where(organization: distributee_org, charge_categories: { code: "ocean_freight" }) }
        let(:original_ocean_freight) { Pricings::Fee.joins(:charge_category).where(organization: organization, charge_categories: { code: "ocean_freight" }) }
        let(:sheet_fee_keys) do
          %w[imo2020 equipment_imbalance_fee ocean_freight peak_season documentation]
        end

        it "inserts the rates from the sheet into the uploading Organization" do
          expect(Pricings::Fee.where(organization: organization).joins(:charge_category).pluck("charge_categories.code").uniq).to match_array(sheet_fee_keys)
        end

        it "inserts the rates from the sheet into the distributee Organization with extra fees" do
          expect(Pricings::Fee.where(organization: distributee_org).joins(:charge_category).pluck("charge_categories.code").uniq).to match_array(
            sheet_fee_keys + ["loading", "export customs", "transport vienna"]
          )
        end

        it "adjusts the fee for the distribution" do
          expect(distributed_ocean_freight.pluck(:rate)).to match_array(original_ocean_freight.map { |fee| fee.rate * 1.15 })
        end
      end
    end
  end
end
