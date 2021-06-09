# frozen_string_literal: true

require "rails_helper"

RSpec.describe DocumentService::TruckingWriter do
  describe "#perform" do
    let(:writer) do
      described_class.new({
        organization_id: organization.id,
        hub_id: hub.id,
        group_id: group.id,
        load_type: load_type
      })
    end

    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:hub) { FactoryBot.create(:legacy_hub, organization: organization) }
    let(:group) { FactoryBot.create(:groups_group, organization: organization) }
    let(:spreadsheet) { Roo::Excelx.new(StringIO.new(writer.legacy_file.attachment)) }
    let!(:trucking) { FactoryBot.create(:trucking_trucking, :updated_load_meterage, cargo_class: cargo_class, load_type: load_type, hub: hub, group: group, organization: organization) }
    let(:fee_headers) do
      %w[FEE
        MOT
        FEE_CODE
        TRUCK_TYPE
        DIRECTION
        CURRENCY
        RATE_BASIS
        TON
        CBM
        KG
        ITEM
        SHIPMENT
        BILL
        CONTAINER
        MINIMUM
        WM
        PERCENTAGE]
    end
    let(:metadata) do
      {
        "CITY" => hub.nexus.name,
        "CURRENCY" => "SEK",
        "SCALE" => "kg",
        "LOAD_METERAGE_HARD_LIMIT" => trucking.load_meterage["hard_limit"],
        "LOAD_METERAGE_STACKABLE_LIMIT" => trucking.load_meterage["stackable_limit"].to_i,
        "LOAD_METERAGE_NON_STACKABLE_LIMIT" => trucking.load_meterage["non_stackable_limit"],
        "LOAD_METERAGE_STACKABLE_TYPE" => trucking.load_meterage["stackable_type"],
        "LOAD_METERAGE_NON_STACKABLE_TYPE" => trucking.load_meterage["non_stackable_type"],
        "LOAD_METERAGE_RATIO" => trucking.load_meterage["ratio"],
        "RATE_BASIS" => "PER_X_KG",
        "BASE" => 100,
        "CBM_RATIO" => trucking.cbm_ratio,
        "TRUCK_TYPE" => trucking.truck_type,
        "LOAD_TYPE" => trucking.load_type,
        "CARGO_CLASS" => trucking.cargo_class,
        "DIRECTION" => "export",
        "CARRIER" => trucking.tenant_vehicle.carrier.name,
        "SERVICE" => trucking.tenant_vehicle.name,
        "EFFECTIVE_DATE" => trucking.validity.first.strftime("%Y-%m-%d"),
        "EXPIRATION_DATE" => (trucking.validity.last + 1.day).strftime("%Y-%m-%d")
      }
    end

    before do
      ::Organizations.current_id = organization.id
      writer.perform
    end

    after do
      writer.legacy_file.destroy
    end

    shared_examples_for "it writes the sheet correctly" do
      it "writes the Zones Sheet correctly", :aggregate_failures do
        expect(spreadsheet.sheet("Zones").row(1)).to eq(%w[ZONE POSTAL_CODE RANGE COUNTRY_CODE])
        expect(spreadsheet.sheet("Zones").row(2)).to eq([0, 15_211, nil, "SE"])
      end

      it "writes the Fees Sheet correctly", :aggregate_failures do
        expect(spreadsheet.sheet("Fees").row(1)).to eq(fee_headers)
        expect(spreadsheet.sheet("Fees").row(2).compact).to eq(["Pickup Fee", "ocean", "PUF", "default", "export", "CNY", "PER_SHIPMENT", 250])
      end

      it "writes the Rates Sheet correctly", :aggregate_failures do
        expect(spreadsheet.sheet("Sheet3").row(1)).to eq(metadata.keys)
        expect(spreadsheet.sheet("Sheet3").row(2)).to eq(metadata.values)
        expect(spreadsheet.sheet("Sheet3").row(3).compact.uniq).to eq(["kg"])
        expect(spreadsheet.sheet("Sheet3").row(4).compact.last).to eq("2500.0 - 5000.0")
        expect(spreadsheet.sheet("Sheet3").row(6)[2, 11]).to match_array(trucking.rates["kg"].map { |r| r["rate"]["value"].round(2) })
      end
    end

    context "when FCL" do
      let(:load_type) { "container" }
      let(:cargo_class) { "fcl_20" }

      it_behaves_like "it writes the sheet correctly"
    end

    context "when LCl" do
      let(:load_type) { "cargo_item" }
      let(:cargo_class) { "lcl" }

      it_behaves_like "it writes the sheet correctly"
    end
  end
end
