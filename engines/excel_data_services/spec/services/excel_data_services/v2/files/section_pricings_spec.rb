# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Section do
  include_context "for excel_data_services setup"

  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    let(:section_string) { "Pricings" }

    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#data" do
    let(:carrier) { Legacy::Carrier.find_by(name: "MSC", code: "msc") }

    shared_examples_for "returns a DataFrame populated by the columns defined in the configs" do
      it "returns a DataFrame of extracted values" do
        expect(service.data).to eq(Rover::DataFrame.new(expected_results))
      end
    end

    context "when section is ChargeCategory" do
      let(:section_string) { "ChargeCategory" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :charge_categories, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end

    context "when section is TenantVehicle" do
      let(:section_string) { "TenantVehicle" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :tenant_vehicles, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end

    context "when section is Carrier" do
      let(:section_string) { "Carrier" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :carriers, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end

    context "when section is Itinerary" do
      let(:section_string) { "Itinerary" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :itineraries, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end

    context "when section is Pricings" do
      let(:section_string) { "Pricings" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :pricings, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end
  end

  describe "#perform" do
    let(:section_string) { "Pricings" }
    let(:carrier) { Legacy::Carrier.find_by(name: "MSC", code: "msc") }
    let(:tenant_vehicle) { Legacy::TenantVehicle.find_by(name: "standard", carrier: carrier, organization: organization) }
    let(:itinerary) { Legacy::Itinerary.find_by(origin_hub: origin_hub, destination_hub: destination_hub, transshipment: nil, organization: organization) }
    let(:transshipment_itinerary) { Legacy::Itinerary.find_by(origin_hub: origin_hub, transshipment: "ZACPT", destination_hub: destination_hub, organization: organization) }
    let(:lcl_pricing) { Pricings::Pricing.find_by(itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "lcl") }
    let(:fcl_40_pricing) { Pricings::Pricing.find_by(itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "fcl_40") }
    let(:fcl_40_hq_pricing) { Pricings::Pricing.find_by(itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "fcl_40_hq") }
    let(:transhipment_lcl_pricing) { Pricings::Pricing.find_by(itinerary: transshipment_itinerary, tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "lcl") }
    let(:transhipment_fcl_20_pricing) { Pricings::Pricing.find_by(itinerary: transshipment_itinerary, tenant_vehicle: tenant_vehicle, organization: organization, cargo_class: "fcl_20") }
    let!(:origin_hub) { FactoryBot.create(:legacy_hub, :gothenburg, organization: organization) }
    let!(:destination_hub) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
    let(:result_state) { service.perform }
    let(:lcl_fee) { Pricings::Fee.find_by(charge_category: pss_charge_category, pricing: lcl_pricing, organization: organization) }
    let(:lcl_range_fee) { Pricings::Fee.find_by(charge_category: baf_charge_category, pricing: lcl_pricing, organization: organization) }
    let(:fcl_40_fee) { Pricings::Fee.find_by(charge_category: ofr_charge_category, pricing: fcl_40_pricing, organization: organization) }
    let(:fcl_40_hq_fee) { Pricings::Fee.find_by(charge_category: ofr_charge_category, pricing: fcl_40_hq_pricing, organization: organization) }
    let(:transhipment_lcl_fee) { Pricings::Fee.find_by(charge_category: bas_charge_category, pricing: transhipment_lcl_pricing, organization: organization) }
    let(:transhipment_fcl_20_ofr_fee) { Pricings::Fee.find_by(charge_category: ofr_charge_category, pricing: transhipment_fcl_20_pricing, organization: organization) }
    let(:transhipment_fcl_20_lss_fee) { Pricings::Fee.find_by(charge_category: lss_charge_category, pricing: transhipment_fcl_20_pricing, organization: organization) }
    let(:bas_charge_category) { Legacy::ChargeCategory.find_by(name: "Ocean Freight", code: "bas", organization: organization) }
    let(:pss_charge_category) { Legacy::ChargeCategory.find_by(name: "Peak Season", code: "pss", organization: organization) }
    let(:baf_charge_category) { Legacy::ChargeCategory.find_by(name: "Bunker Adjustment Fee", code: "baf", organization: organization) }
    let(:ofr_charge_category) { Legacy::ChargeCategory.find_by(name: "OFR", code: "ofr", organization: organization) }
    let(:lss_charge_category) { Legacy::ChargeCategory.find_by(name: "LSS", code: "lss", organization: organization) }

    before do
      FactoryBot.create(:pricings_rate_basis, external_code: "PER_WM")
      FactoryBot.create(:pricings_rate_basis, external_code: "PER_CONTAINER")
      result_state
    end

    it "returns a State object after inserting Data", :aggregate_failures do
      expect(result_state).to be_a(ExcelDataServices::V2::State)
      expect(lcl_pricing).to be_present
      expect(fcl_40_pricing).to be_present
      expect(transhipment_lcl_pricing).to be_present
      expect(transhipment_fcl_20_pricing).to be_present
    end

    it "returns inserts the lcl fees ", :aggregate_failures do
      expect(lcl_fee.rate).to eq(40)
      expect(lcl_range_fee.range).to match_array([{ "max" => "100.0", "min" => "0.0", "rate" => 210.0 }, { "max" => "500.0", "min" => "100.0", "rate" => 110.0 }])
      expect(transhipment_lcl_fee.rate).to eq(210)
    end

    it "returns a dynamic fcl fees", :aggregate_failures do
      expect(fcl_40_fee.rate).to eq(4660)
      expect(fcl_40_hq_fee.rate).to eq(5330)
      expect(transhipment_fcl_20_ofr_fee.rate).to eq(4330)
      expect(transhipment_fcl_20_lss_fee.rate).to eq(200)
    end
  end
end
