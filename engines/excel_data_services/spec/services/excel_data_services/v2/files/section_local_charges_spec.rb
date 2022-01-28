# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Section do
  include_context "for excel_data_services setup"

  let(:xlsx) { File.open(file_fixture("excel/example_local_charges.xlsx")) }
  let(:service) { described_class.new(state: state_arguments) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_state) { service.perform }
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }
  let!(:shanghai) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
  let!(:felixstowe) { FactoryBot.create(:legacy_hub, :felixstowe, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#valid?" do
    let(:section_string) { "LocalCharges" }

    it "returns successfully" do
      expect(service.valid?).to eq(true)
    end
  end

  describe "#data" do
    shared_examples_for "returns a DataFrame populated by the columns defined in the configs" do
      it "returns a DataFrame of extracted values" do
        expect(service.data[0..2].to_a).to match_array(expected_results.to_a)
      end
    end

    context "when section is LocalCharges" do
      let(:section_string) { "LocalCharges" }
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :local_charges, organization: organization, default_group: default_group) }

      it_behaves_like "returns a DataFrame populated by the columns defined in the configs"
    end
  end

  describe "#perform" do
    let(:section_string) { "LocalCharges" }
    let(:carrier) { Legacy::Carrier.find_by(name: "MSC", code: "msc") }
    let(:tenant_vehicle) { Legacy::TenantVehicle.find_by(name: "standard", carrier: carrier, organization: organization) }
    let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }

    let(:result_state) { service.perform }

    before do
      %w[
        PER_TON
        PER_CBM
        PER_KG
        PER_ITEM
        PER_SHIPMENT
        PER_BILL
        PER_CONTAINER
        PER_WM
        PERCENTAGE
        PER_KG_RANGE
        PER_X_KG
      ].each { |rate_basis| FactoryBot.create(:pricings_rate_basis, external_code: rate_basis) }
      FactoryBot.create(:groups_group, organization: organization, name: "Local Charges Group One")
    end

    it "returns a State object after inserting Data", :aggregate_failures do
      expect(result_state).to be_a(ExcelDataServices::V2::State)
      expect(result_state.errors).to be_empty
    end

    context "when local charges are expanded for counterpart hubs" do
      before do
        organization.scope.update(content: { expand_non_counterpart_local_charges: true })
        result_state
      end

      let(:xlsx) { File.open(file_fixture("excel/example_local_charges_counterpart_expansion.xlsx")) }
      let(:base_local_charge) { hamburg.local_charges.find_by(counterpart_hub_id: nil) }

      it "creates a LocalCharge for each pair and the counterpart agnostic fees are duplicated in the counterpart LocalCharges", :aggregate_failures do
        expect(hamburg.local_charges.find_by(counterpart_hub: shanghai).fees.keys).to match_array(base_local_charge.fees.keys + ["HDL"])
        expect(hamburg.local_charges.find_by(counterpart_hub: felixstowe).fees.keys).to match_array(base_local_charge.fees.keys + ["ISP"])
      end
    end
  end
end
