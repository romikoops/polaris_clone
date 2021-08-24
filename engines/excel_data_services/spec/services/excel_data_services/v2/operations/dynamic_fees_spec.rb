# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Operations::DynamicFees do
  include_context "for excel_data_services extractor setup"

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
      "country_origin" => "Sweden",
      "destination_locode" => "CNSHA",
      "destination" => "Shanghai",
      "country_destination" => "China",
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
      "ofr" => "5330.0",
      "lss" => "300.0" }
  end
  let(:extracted_table) { described_class.state(state: state_arguments).frame }

  describe ".data" do
    it "returns the turns each row into a row for each fee defined in the dynamic columns", :aggregate_failures do
      expect(extracted_table[extracted_table["fee_code"] == "ofr"]["rate"].to_a).to eq([row["ofr"]])
      expect(extracted_table[extracted_table["fee_code"] == "lss"]["rate"].to_a).to eq([row["lss"]])
    end
  end
end
