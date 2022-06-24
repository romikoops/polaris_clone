# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "Saco Shipping", code: "saco_shipping") }
  let!(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization) }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let!(:default_group) { Groups::Group.find_by(organization: organization, name: "default") || FactoryBot.create(:groups_group, organization: organization, name: "default") }

  let(:xlsx) { File.open(file_fixture("excel/example_saco_import.xlsx")) }
  let!(:arbue) do
    FactoryBot.create(:legacy_hub, name: "Buenos Aires", organization: organization, hub_code: "ARBUE", nexus:	FactoryBot.build(:legacy_nexus, organization: organization, locode: "ARBUE", country: factory_country_from_code(code: "AR")))
  end
  let!(:armdz) do
    FactoryBot.create(:legacy_hub, name: "Mendoza", organization: organization, hub_code: "ARMDZ", nexus:	FactoryBot.build(:legacy_nexus, organization: organization, locode: "ARMDZ", country: factory_country_from_code(code: "AR")))
  end
  let!(:cnaqg) do
    FactoryBot.create(:legacy_hub, name: "Anqing", organization: organization, hub_code: "CNAQG", nexus:	FactoryBot.build(:legacy_nexus, organization: organization, locode: "CNAQG", country: factory_country_from_code(code: "CN")))
  end
  let!(:crsjo) do
    FactoryBot.create(:legacy_hub, name: "San José", organization: organization, hub_code: "CRSJO", nexus:	FactoryBot.build(:legacy_nexus, organization: organization, locode: "CRSJO", country: factory_country_from_code(code: "CR")))
  end
  let(:pricings) { Pricings::Pricing.where(organization: organization).joins(fees: :charge_category).joins(:itinerary) }

  before do
    FactoryBot.create(:pricings_rate_basis, external_code: "W/M", internal_code: "PER_WM")
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    let(:result_stats) { service.perform }
    let(:mendoza_hamburg_pricing) do
      pricings.find_by(
        tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "lcl", group: default_group,
        itineraries: { origin_hub_id: armdz.id, destination_hub_id: hamburg.id, transshipment: "Buenos Aires" }
      )
    end
    let(:buenos_aires_hamburg_pricing) do
      pricings.find_by(
        tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "lcl", group: default_group,
        itineraries: { origin_hub_id: arbue.id, destination_hub_id: hamburg.id, transshipment: nil }
      )
    end
    let(:anqing_hamburg_pricing) do
      pricings.find_by(
        tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "lcl", group: default_group,
        itineraries: { origin_hub_id: cnaqg.id, destination_hub_id: hamburg.id, transshipment: "Shanghai" }
      )
    end
    let(:san_jose_hamburg_pricing) do
      pricings.find_by(
        tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "lcl", group: default_group,
        itineraries: { origin_hub_id: crsjo.id, destination_hub_id: hamburg.id, transshipment: nil }
      )
    end

    before { service.perform }

    it "returns inserts 3 Pricings, ignoring the 'on-request' rate", :aggregate_failures do
      expect(mendoza_hamburg_pricing).not_to be_present
      expect(buenos_aires_hamburg_pricing).to be_present
      expect(anqing_hamburg_pricing).to be_present
      expect(san_jose_hamburg_pricing).to be_present
    end

    it "adds a pre carriage fee if data is present" do
      pre_carriage_fee = anqing_hamburg_pricing.fees.joins(:charge_category).find_by(charge_categories: { code: "pre_carriage" })
      expect(pre_carriage_fee.rate).to eq(45.0)
    end

    it "parses the wm rate from the second basis column" do
      expect(san_jose_hamburg_pricing.wm_rate).to eq(500)
    end

    it "creates included fees where listed in the second basis column" do
      fee_codes = buenos_aires_hamburg_pricing.fees.map { |fee| fee.charge_category.code }
      expect(fee_codes).to match_array(%w[bas included_caf included_baf included_ohc])
    end
  end

  describe "#valid?" do
    context "with an empty sheet" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "with an saco import sheet" do
      let(:xlsx) { File.open(file_fixture("excel/example_saco_import.xlsx")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
