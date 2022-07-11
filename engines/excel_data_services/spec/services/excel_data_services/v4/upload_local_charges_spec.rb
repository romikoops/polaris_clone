# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Upload do
  include_context "V4 setup"

  let(:service) { described_class.new(file: file, arguments: {}) }
  let(:carrier) { FactoryBot.create(:legacy_carrier, name: "SSC", code: "ssc") }
  let!(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: organization) }
  let!(:hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: organization) }
  let!(:test_group) { FactoryBot.create(:groups_group, organization: organization, name: "Local Charges Group One") }

  let(:xlsx) { File.open(file_fixture("excel/example_local_charges.xlsx")) }

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
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    let(:result_stats) { service.perform }
    let(:local_charge) { Legacy::LocalCharge.find_by(organization: organization, hub: hamburg, tenant_vehicle: tenant_vehicle, group: test_group) }

    context "without counterpart hub codes" do
      before { service.perform }

      expected_fee_data = [{ "key" => "AA", "max" => nil, "min" => nil, "base" => nil, "name" => "AA Fee", "range" => [], "currency" => "EUR", "container" => "12.0", "rate_basis" => "PER_CONTAINER", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "wm" => "13.0", "key" => "BB", "max" => nil, "min" => nil, "base" => nil, "name" => "BB Fee", "range" => [], "currency" => "EUR", "rate_basis" => "PER_WM", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "BL", "max" => nil, "min" => nil, "ton" => "4.0", "base" => nil, "name" => "B/L Fee", "range" => [], "currency" => "EUR", "rate_basis" => "PER_TON", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "CC", "max" => nil, "min" => nil, "base" => nil, "name" => "CC Fee", "range" => [], "currency" => "EUR", "percentage" => "23.0", "rate_basis" => "PERCENTAGE", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "DD", "max" => nil, "min" => nil, "base" => nil, "name" => "DD Fee", "range" => [{ "kg" => "5.0", "max" => 100.0, "min" => 0.0 }], "currency" => "EUR", "rate_basis" => "PER_KG_RANGE", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "EE", "max" => nil, "min" => nil, "base" => nil, "name" => "EE Fee", "range" => [{ "kg" => "2.0", "max" => 200.0, "min" => 100.0 }], "currency" => "EUR", "rate_basis" => "PER_KG_RANGE", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "kg" => "30.0", "key" => "FF", "max" => nil, "min" => nil, "base" => "100.0", "name" => "FF Fee", "range" => [], "currency" => "EUR", "rate_basis" => "PER_X_KG", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "SC", "max" => nil, "min" => "30.0", "base" => nil, "bill" => "9.0", "name" => "LCL Service Charge", "range" => [], "currency" => "EUR", "rate_basis" => "PER_BILL", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "kg" => "6.0", "key" => "HDL", "max" => nil, "min" => nil, "base" => nil, "name" => "Handling Fee", "range" => [], "currency" => "EUR", "rate_basis" => "PER_KG", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "ISP", "max" => nil, "min" => nil, "base" => nil, "item" => "7.0", "name" => "ISPS Fee", "range" => [], "currency" => "EUR", "rate_basis" => "PER_ITEM", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "key" => "SOL", "max" => nil, "min" => nil, "base" => nil, "name" => "SOLAS Fee", "range" => [], "currency" => "EUR", "shipment" => "8.0", "rate_basis" => "PER_SHIPMENT", "cbm_ratio" => 1000, "vm_ratio" => 1 },
        { "cbm" => "5.0", "key" => "CUSTOMS DOC", "max" => nil, "min" => nil, "base" => nil, "name" => "CUSTOMS DOC", "range" => [], "currency" => "EUR", "rate_basis" => "PER_CBM", "cbm_ratio" => 1000, "vm_ratio" => 1 }]

      it "returns inserts the local charge with all fees formatted properly", :aggregate_failures do
        expect(local_charge.fees.values).to eq(expected_fee_data)
        expect(local_charge.fees.keys).to eq(expected_fee_data.pluck("key"))
      end
    end

    context "when local charges are expanded for counterpart hubs" do
      let!(:felixstowe) { FactoryBot.create(:legacy_hub, :felixstowe, organization: organization) }
      let!(:shanghai) { FactoryBot.create(:legacy_hub, :shanghai, organization: organization) }
      let(:xlsx) { File.open(file_fixture("excel/example_local_charges_counterpart_expansion.xlsx")) }
      let(:base_local_charge) { hamburg.local_charges.find_by(counterpart_hub_id: nil) }

      before do
        organization.scope.update(content: { expand_non_counterpart_local_charges: true })
        service.perform
      end

      it "creates a LocalCharge for each pair and the counterpart agnostic fees are duplicated in the counterpart LocalCharges", :aggregate_failures do
        expect(hamburg.local_charges.find_by(counterpart_hub: shanghai).fees.keys).to match_array(base_local_charge.fees.keys + ["HDL"])
        expect(hamburg.local_charges.find_by(counterpart_hub: felixstowe).fees.keys).to match_array(base_local_charge.fees.keys + ["ISP"])
      end
    end

    context "with distribution" do
      let(:service) { described_class.new(file: file, arguments: { distribute: true }) }
      let!(:distributed_tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "standard", carrier: carrier, organization: distributee_org, mode_of_transport: "ocean") }
      let!(:distributee_hamburg) { FactoryBot.create(:legacy_hub, :hamburg, organization: distributee_org) }
      let(:local_charge) { Legacy::LocalCharge.find_by(organization: distributee_org, hub: distributee_hamburg, tenant_vehicle: distributed_tenant_vehicle, group: distributed_test_group) }
      let!(:distributed_test_group) { FactoryBot.create(:groups_group, organization: distributee_org, name: "Local Charges Group One") }
      let!(:distributee_org) { FactoryBot.create(:organizations_organization, slug: "distributed") }

      before do
        FactoryBot.create(:distributions_action, :duplicate,
          organization: organization,
          upload_schema: "local_charge",
          target_organization: distributee_org,
          where: { locode: hamburg.locode, fee_code: "aa" },
          order: 1)
        FactoryBot.create(:distributions_action, :adjust_fee,
          organization: organization,
          upload_schema: "local_charge",
          target_organization: distributee_org,
          order: 2,
          where: { fee_code: "aa" },
          arguments: { operator: "+", value: 5 })
        FactoryBot.create(:groups_group, name: "default", organization: distributee_org)
        service.perform
      end

      it "copies only the 'aa' fee" do
        expect(local_charge.fees["AA"]).to eq({ "key" => "AA", "max" => nil, "min" => nil, "base" => nil, "name" => "AA Fee", "range" => [], "currency" => "EUR", "container" => "17.0", "rate_basis" => "PER_CONTAINER", "cbm_ratio" => 1000, "vm_ratio" => 1 })
      end
    end
  end

  describe "#valid?" do
    context "with an empty sheet" do
      let(:xlsx) { File.open(file_fixture("excel/empty.xlsx")) }

      it "is invalid" do
        expect(service).not_to be_valid
      end
    end

    context "with an local charges sheet" do
      let(:xlsx) { File.open(file_fixture("excel/example_local_charges.xlsx")) }

      it "is valid" do
        expect(service).to be_valid
      end
    end
  end
end
