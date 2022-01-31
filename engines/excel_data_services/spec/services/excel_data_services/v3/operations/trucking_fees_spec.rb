# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Operations::TruckingFees do
  include_context "V3 setup"

  let(:extracted_table) { described_class.state(state: state_arguments).frame }
  let(:non_fees_rows) do
    test_groupings.map do |test_grouping|
      {
        "zone" => "1.0",
        "postal_code" => "20457",
        "country_code" => "DE",
        "service" => "standard",
        "carrier" => "Test Carrier",
        "carrier_code" => "test carrier",
        "direction" => "export",
        "cargo_class" => "fcl_20",
        "load_type" => "cargo_item",
        "rate_type" => "trucking_rate",
        "truck_type" => "default",
        "effective_date" => Date.parse("Tue, 01 Sep 2020"),
        "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
        "cbm_ratio" => 250.0,
        "organization_id" => organization.id,
        "identifier" => "postal_code",
        "sheet_name" => "Sheet1"
      }.merge(test_grouping)
    end
  end
  let(:test_groupings) { [{ "zone" => "1.0" }, { "zone" => "2.0" }] }
  let(:rows) { non_fees_rows + [row] }
  let(:expanded_fees) { extracted_table[extracted_table["rate_type"] == "trucking_fee"] }
  let(:row) do
    { "zone" => nil,
      "range" => nil,
      "country_code" => nil,
      "postal_code" => nil,
      "sheet_name" => "Fees",
      "hub_id" => 8128,
      "organization_id" => organization.id,
      "row" => 0,
      "zone_row" => nil,
      "rate" => 30.0,
      "rate_type" => "trucking_fee",
      "fee_code" => "fsc",
      "fee_name" => "Fuel Surcharge Fee",
      "column" => 0,
      "service" => nil,
      "carrier" => nil,
      "carrier_code" => nil,
      "direction" => "export",
      "cargo_class" => nil,
      "load_type" => nil,
      "truck_type" => "default",
      "currency" => "EUR",
      "base" => nil,
      "rate_basis" => "PER_SHIPMENT",
      "group_name" => nil,
      "group_id" => nil,
      "min" => nil,
      "max" => nil,
      "mode_of_transport" => "truck_carriage",
      "identifier" => "postal_code" }.merge(test_overrides)
  end

  describe "#perform" do
    context "when nothing is defined it attaches to all rates" do
      let(:test_overrides) { {} }

      it "returns fees expanded for all rates", :aggregate_failures do
        expect(expanded_fees["zone"].to_a).to eq(["1.0", "2.0"])
        expect(expanded_fees["cargo_class"].to_a).to eq(["fcl_20"] * 2)
        expect(expanded_fees["service"].to_a).to eq(["standard"] * 2)
        expect(expanded_fees["carrier_code"].to_a).to eq(["test carrier"] * 2)
      end
    end

    context "when zone is defined it attaches only to rates of that zone" do
      let(:test_overrides) { { "zone" => "1.0" } }

      it "returns fees that match the filter params", :aggregate_failures do
        expect(expanded_fees["zone"].to_a).to eq(["1.0"])
        expect(expanded_fees["cargo_class"].to_a).to eq(["fcl_20"])
        expect(expanded_fees["service"].to_a).to eq(["standard"])
        expect(expanded_fees["carrier_code"].to_a).to eq(["test carrier"])
      end
    end

    context "when cargo_class is defined it attaches only to rates of that cargo_class" do
      let(:test_groupings) do
        [
          { "zone" => "1.0", "cargo_class" => "fcl_20", "sheet_name" => "Sheet1" },
          { "zone" => "2.0", "cargo_class" => "fcl_40", "sheet_name" => "Sheet2" }
        ]
      end
      let(:test_overrides) { { "cargo_class" => "fcl_40" } }

      it "returns fees that match the filter params", :aggregate_failures do
        expect(expanded_fees["zone"].to_a).to eq(["2.0"])
        expect(expanded_fees["cargo_class"].to_a).to eq(["fcl_40"])
        expect(expanded_fees["service"].to_a).to eq(["standard"])
        expect(expanded_fees["carrier_code"].to_a).to eq(["test carrier"])
      end
    end

    context "when service & carrier is defined it attaches only to rates of that service & carrier" do
      let(:test_groupings) do
        [
          { "service" => "standard", "carrier" => "Test Carrier", "sheet_name" => "Sheet1" },
          { "service" => "fast", "carrier" => "Test Carrier", "sheet_name" => "Sheet2" }
        ]
      end
      let(:test_overrides) { { "service" => "standard", "carrier" => "Test Carrier", "carrier_code" => "test carrier" } }

      it "returns fees that match the filter params", :aggregate_failures do
        expect(expanded_fees["zone"].to_a).to eq(["1.0"])
        expect(expanded_fees["cargo_class"].to_a).to eq(["fcl_20"])
        expect(expanded_fees["service"].to_a).to eq(["standard"])
        expect(expanded_fees["carrier_code"].to_a).to eq(["test carrier"])
      end
    end

    context "when all fields are defined it assigns the fees correctly" do
      let(:test_overrides) do
        {
          "service" => "fast",
          "carrier" => "Test Carrier",
          "carrier_code" => "test carrier",
          "zone" => "2.0",
          "cargo_class" => "fcl_20"
        }
      end
      let(:test_groupings) do
        [
          {
            "zone" => "1.0",
            "cargo_class" => "fcl_20",
            "service" => "standard",
            "carrier" => "Test Carrier",
            "carrier_code" => "test carrier",
            "sheet_name" => "Sheet1"
          },
          {
            "zone" => "2.0",
            "cargo_class" => "fcl_20",
            "service" => "fast",
            "carrier" => "Test Carrier",
            "carrier_code" => "test carrier",
            "sheet_name" => "Sheet2"
          }
        ]
      end

      it "returns fees that match the filter params", :aggregate_failures do
        expect(expanded_fees["zone"].to_a).to eq(["2.0"])
        expect(expanded_fees["cargo_class"].to_a).to eq(["fcl_20"])
        expect(expanded_fees["service"].to_a).to eq(["fast"])
        expect(expanded_fees["carrier_code"].to_a).to eq(["test carrier"])
      end
    end

    context "when all fields are defined it assigns no fees match" do
      let(:test_overrides) do
        {
          "service" => "slow",
          "carrier" => "Test Carrier",
          "carrier_code" => "test carrier",
          "zone" => "2.0",
          "cargo_class" => "fcl_20"
        }
      end
      let(:test_groupings) { [{ "zone" => "1.0" }, { "zone" => "2.0" }] }

      it "returns empty frame" do
        expect(expanded_fees).to be_empty
      end
    end
  end
end
