# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::SheetType do
  include_context "for excel_data_services setup"
  let(:service) { described_class.new(type: "Pricings", file: file, arguments: arguments) }
  let(:arguments) { {} }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    it "returns true when the sheet is pricings sheet" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#perform (unit)" do
    let(:pipeline) { instance_double("ExcelDataServices::V2::Files::Section", perform: dummy_state) }
    let(:pipelines) { [pipeline] }
    let(:dummy_state) { instance_double("ExcelDataServices::V2::State", errors: [], stats: [{}]) }

    before do
      allow(service).to receive(:pipelines).and_return(pipelines)
    end

    context "when no errors occur on a single pipeline" do
      it "triggers the pipelines and returns the State object", :aggregate_failures do
        expect(service.perform).to be_a(ExcelDataServices::V2::State)
        expect(pipeline).to have_received(:perform)
        expect(dummy_state).to have_received(:errors)
        expect(dummy_state).to have_received(:stats)
      end
    end

    context "when an error occur on a single pipeline" do
      let(:error_state) { instance_double("ExcelDataServices::V2::State", errors: ["There was an error"], stats: [{}]) }
      let(:error_pipeline) { instance_double("ExcelDataServices::V2::Files::Section", perform: error_state) }
      let(:pipelines) { [error_pipeline, pipeline] }

      it "triggers the pipelines and returns the State object", :aggregate_failures do
        expect(service.perform).to be_a(ExcelDataServices::V2::State)
        expect(pipeline).not_to have_received(:perform)
      end
    end
  end

  describe "#perform (integration)" do
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

    context "when an error occurs" do
      before do
        organization.scope.update(content: { atomic_insert: true })
        service.perform
      end

      let(:origin_hub) { nil }

      it "does not persist any data", :aggregate_failures do
        expect(Pricings::Pricing.all).to be_empty
        expect(Pricings::Fee.all).to be_empty
      end
    end
  end

  describe ".state" do
    let(:arguments) { { group_id: SecureRandom.uuid } }
    let(:state) { service.state }

    it "returns a V2::State object with the correct Overrides defined", :aggregate_failures do
      expect(state).to be_a(ExcelDataServices::V2::State)
      expect(state.overrides.group_id).to eq(arguments[:group_id])
    end
  end
end
