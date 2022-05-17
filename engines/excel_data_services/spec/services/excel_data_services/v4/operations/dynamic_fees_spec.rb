# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Operations::DynamicFees do
  include_context "V4 setup"

  let(:extracted_table) { described_class.state(state: state_arguments).frame }

  describe "#data" do
    context "with simple dynamic columns" do
      let(:row) do
        { "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "group_id" => nil,
          "group_name" => nil,
          "effective_date" => Date.parse("Tue, 29 Dec 2020"),
          "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
          "origin_locode" => "SEGOT",
          "origin" => "Gothenburg",
          "origin_country" => "Sweden",
          "destination_locode" => "CNSHA",
          "destination" => "Shanghai",
          "destination_country" => "China",
          "mode_of_transport" => "ocean",
          "carrier" => "msc",
          "service_level" => "standard",
          "cargo_class" => "fcl_20",
          "internal" => nil,
          "transshipment" => nil,
          "fee_name" => nil,
          "fee_code" => nil,
          "rate" => nil,
          "rate_basis" => "PER_CONTAINER",
          "range_min" => nil,
          "range_max" => nil,
          "base" => nil,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "organization_id" => organization.id,
          "Dynamic(Sheet1-11):ofr" => "5330.0",
          "Dynamic(Sheet1-12):lss" => "300.0",
          "remarks" => nil }
      end

      it "returns the turns each row into a row for each fee defined in the dynamic columns", :aggregate_failures do
        expect(extracted_table[extracted_table["fee_code"] == "ofr"]["rate"].to_a).to eq([row["Dynamic(Sheet1-11):ofr"]])
        expect(extracted_table[extracted_table["fee_code"] == "lss"]["rate"].to_a).to eq([row["Dynamic(Sheet1-12):lss"]])
      end
    end

    context "with complex dynamic columns" do
      let(:row) do
        { "service" => "standard",
          "row" => 3,
          "sheet_name" => "Sheet2",
          "group_id" => nil,
          "group_name" => nil,
          "effective_date" => Date.parse("1 Nov 2021"),
          "expiration_date" => Date.parse("31 Dec 2021"),
          "origin_locode" => "SEGOT",
          "origin" => "Gothenburg",
          "origin_country" => "Sweden",
          "destination_locode" => "CNSHA",
          "destination" => "Shanghai",
          "destination_country" => "China",
          "mode_of_transport" => "ocean",
          "carrier" => "msc",
          "service_level" => "standard",
          "cargo_class" => nil,
          "internal" => nil,
          "transshipment" => nil,
          "fee_name" => nil,
          "fee_code" => nil,
          "rate" => nil,
          "rate_basis" => "PER_CONTAINER",
          "range_min" => nil,
          "range_max" => nil,
          "base" => nil,
          "origin_terminal" => nil,
          "destination_terminal" => nil,
          "remarks" => nil,
          "organization_id" => organization.id,
          "Dynamic(Sheet1-11):curr_month/baf" => "DEZ",
          "Dynamic(Sheet1-12):curr_fee/20/baf" => Money.new(2500, "USD"),
          "Dynamic(Sheet1-13):curr_fee/40/baf" => Money.new(3500, "USD"),
          "Dynamic(Sheet1-14):next_month/baf" => "JAN",
          "Dynamic(Sheet1-15):next_fee/20/baf" => "n/a",
          "Dynamic(Sheet1-16):next_fee/40/baf" => "incl",
          "Dynamic(Sheet1-17):note/import_fees_required" => "x" }
      end

      it "returns combines the dynamic columns to create a row per fee per cargo class, ignoring months outside of dates", :aggregate_failures do
        expect(extracted_table[extracted_table["fee_code"] == "baf"]["rate"].to_a.uniq).to match_array([25.0, 35.0])
        expect(extracted_table[extracted_table["fee_code"] == "baf"]["currency"].to_a.uniq).to match_array(["USD"])
        expect(extracted_table[extracted_table["remarks"].missing]).to be_empty
      end
    end

    context "with full range of dynamic columns and data" do
      let(:row) do
        { "carrier_code" => "cma cgm",
          "row" => 1,
          "cargo_class" => nil,
          "sheet_name" => "Africa",
          "effective_date" => Date.parse("Wed, 01 Sep 2021"),
          "expiration_date" => Date.parse("Thu, 30 Sep 2021"),
          "origin_locode" => "DEHAM",
          "destination_locode" => "AOCAB",
          "destination" => "Cabinda",
          "destination_country" => "Angola",
          "mode_of_transport" => "ocean",
          "carrier" => "CMA CGM",
          "service" => "standard",
          "internal" => nil,
          "fee_code" => nil,
          "transshipment" => "CGPNR",
          "destination_terminal" => nil,
          "rate_basis" => "PER_CONTAINER",
          "remarks" => nil,
          "Dynamic(Sheet1-11):20dc" => "n/a",
          "Dynamic(Sheet1-12):40dc" => Money.new(532_500.0, "EUR"),
          "Dynamic(Sheet1-13):40hq" => Money.new(532_500.0, "EUR"),
          "Dynamic(Sheet1-14):int/ref_nr" => "FL4222-ERF-A-002",
          "Dynamic(Sheet1-15):20/lsf" => "incl",
          "Dynamic(Sheet1-16):40/lsf" => "incl",
          "Dynamic(Sheet1-17):curr_month/baf" => "SEP",
          "Dynamic(Sheet1-18):curr_fee/20/baf" => "incl",
          "Dynamic(Sheet1-19):curr_fee/40/baf" => "incl",
          "Dynamic(Sheet1-20):next_month/baf" => "OCT",
          "Dynamic(Sheet1-21):next_fee/20/baf" => "n/a",
          "Dynamic(Sheet1-22):next_fee/40/baf" => "n/a",
          "Dynamic(Sheet1-23):20/imo2020" => "n/a",
          "Dynamic(Sheet1-24):40/imo2020" => "n/a",
          "Dynamic(Sheet1-25):thc" => Money.new(24_000.0, "EUR"),
          "Dynamic(Sheet1-26):curr_month/caf" => "SEP",
          "Dynamic(Sheet1-27):curr_fee/20/caf" => "incl",
          "Dynamic(Sheet1-28):curr_fee/40/caf" => "incl",
          "Dynamic(Sheet1-29):next_month/caf" => "OCT",
          "Dynamic(Sheet1-30):next_fee/20/caf" => "incl",
          "Dynamic(Sheet1-31):next_fee/40/caf" => "incl",
          "Dynamic(Sheet1-32):int/20/imo" => "n/a",
          "Dynamic(Sheet1-33):int/40/imo" => "n/a",
          "Dynamic(Sheet1-34):20/ebs" => "n/a",
          "Dynamic(Sheet1-35):40/ebs" => "n/a",
          "Dynamic(Sheet1-36):isps" => Money.new(2900.0, "EUR"),
          "Dynamic(Sheet1-37):20/port_add" => "n/a",
          "Dynamic(Sheet1-38):40/port_add" => "n/a",
          "Dynamic(Sheet1-39):20/congestion" => Money.new(29_000.0, "EUR"),
          "Dynamic(Sheet1-40):40/congestion" => Money.new(36_000.0, "EUR"),
          "Dynamic(Sheet1-41):20/emergency_imbalance_surcharge" => "n/a",
          "Dynamic(Sheet1-40):40/emergency_imbalance_surcharge" => "n/a",
          "Dynamic(Sheet1-43):20/operation_cost_contribution" => "n/a",
          "Dynamic(Sheet1-44):40/operation_cost_contribution" => "n/a",
          "Dynamic(Sheet1-45):20/piracy_risk" => "n/a",
          "Dynamic(Sheet1-46):40/piracy_risk" => "n/a",
          "Dynamic(Sheet1-47):20/liner out charges (prepaid)" => "n/a",
          "Dynamic(Sheet1-48):40/liner out charges (prepaid)" => "n/a",
          "Dynamic(Sheet1-49):20/export_decl_surcharge" => "n/a",
          "Dynamic(Sheet1-50):40/export_decl_ sc" => "n/a",
          "Dynamic(Sheet1-51):note/coc zertifikat erforderlich" => "n/a",
          "Dynamic(Sheet1-52):20/pss_surcharge" => Money.new(20_000.0, "EUR"),
          "Dynamic(Sheet1-53):40/pss_surcharge" => Money.new(20_000.0, "EUR"),
          "Dynamic(Sheet1-54):note/electronic cargo tracking note/waiver (ectn/besc)" => "x",
          "Dynamic(Sheet1-55):note/import lizenz nr. (form m)" => "x",
          "Dynamic(Sheet1-56):20/dest/isps" => "n/a",
          "Dynamic(Sheet1-57):40/dest/isps" => "n/a",
          "Dynamic(Sheet1-58):20/dest/thc" => "n/a",
          "Dynamic(Sheet1-59):40/dest/thc" => "n/a",
          "Dynamic(Sheet1-60):doc_fee_bl" => "n/a",
          "Dynamic(Sheet1-61):filing_bl" => "n/a",
          "Dynamic(Sheet1-62):int/freetime_at_destination" => nil,
          "organization_id" => organization.id }
      end

      it "excludes the n/a rates correctly", :aggregate_failures do
        expect(extracted_table.filter("fee_code" => "emergency_imbalance_surcharge")).to be_empty
        expect(extracted_table.filter("fee_code" => "operation_cost_contribution")).to be_empty
        expect(extracted_table.filter("fee_code" => "piracy_risk")).to be_empty
        expect(extracted_table.filter("fee_code" => "bas", "cargo_class" => "fcl_20")).to be_empty
      end

      it "dynamically changes the fee code if the value", :aggregate_failures do
        expect(extracted_table.filter("fee_code" => "included_caf")).not_to be_empty
        expect(extracted_table.filter("fee_code" => "included_baf")).not_to be_empty
      end

      it "adds the note headers to the remarks column", :aggregate_failures do
        expect(extracted_table["remarks"].to_a.uniq).to match_array([
          "electronic cargo tracking note/waiver (ectn/besc)",
          "import lizenz nr. (form m)"
        ].map(&:upcase))
        expect(extracted_table.filter("fee_code" => "included_baf")).not_to be_empty
      end
    end
  end
end
