# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Framers::TruckingRates do
  let(:result_frame) { described_class.new(frame: Rover::DataFrame.new(frame_data)).perform }

  describe "#perform" do
    let(:frame_data) do
      [
        { "value" => "postal_code", "header" => "identifier", "row" => 1, "column" => "B", "sheet_name" => "Zones" },
        { "value" => "1.0", "header" => "zone", "row" => 2, "column" => "A", "sheet_name" => "Zones" },
        { "value" => "20037 - 20039", "header" => "range", "row" => 2, "column" => "C", "sheet_name" => "Zones" },
        { "value" => "DE", "header" => "country_code", "row" => 2, "column" => "D", "sheet_name" => "Zones" },
        { "value" => nil, "header" => "postal_code", "row" => 2, "column" => "B", "sheet_name" => "Zones" },
        { "value" => "standard", "header" => "service", "row" => 2, "column" => "L", "sheet_name" => "Sheet3" },
        { "value" => "Gateway Cargo GmbH", "header" => "carrier", "row" => 2, "column" => "K", "sheet_name" => "Sheet3" },
        { "value" => "gateway cargo gmbh", "header" => "carrier_code", "row" => 2, "column" => "K", "sheet_name" => "Sheet3" },
        { "value" => "export", "header" => "direction", "row" => 2, "column" => "J", "sheet_name" => "Sheet3" },
        { "value" => "lcl", "header" => "cargo_class", "row" => 2, "column" => "I", "sheet_name" => "Sheet3" },
        { "value" => "cargo_item", "header" => "load_type", "row" => 2, "column" => "H", "sheet_name" => "Sheet3" },
        { "value" => "default", "header" => "truck_type", "row" => 2, "column" => "G", "sheet_name" => "Sheet3" },
        { "value" => Date.parse("Tue, 01 Sep 2020"), "header" => "effective_date", "row" => 2, "column" => "M", "sheet_name" => "Sheet3" },
        { "value" => Date.parse("Fri, 31 Dec 2021"), "header" => "expiration_date", "row" => 2, "column" => "N", "sheet_name" => "Sheet3" },
        { "value" => 0.25e3, "header" => "cbm_ratio", "row" => 2, "column" => "C", "sheet_name" => "Sheet3" },
        { "value" => "EUR", "header" => "currency", "row" => 2, "column" => "B", "sheet_name" => "Sheet3" },
        { "value" => 0.1e1, "header" => "base", "row" => 2, "column" => "F", "sheet_name" => "Sheet3" },
        { "value" => 0.8e1, "header" => "load_meterage_stackable_limit", "row" => 2, "column" => "P", "sheet_name" => "Sheet3" },
        { "value" => 0.5e1, "header" => "load_meterage_non_stackable_limit", "row" => 2, "column" => "Q", "sheet_name" => "Sheet3" },
        { "value" => false, "header" => "load_meterage_hard_limit", "row" => 2, "column" => "R", "sheet_name" => "Sheet3" },
        { "value" => "area", "header" => "load_meterage_stackable_type", "row" => 2, "column" => "S", "sheet_name" => "Sheet3" },
        { "value" => "ldm", "header" => "load_meterage_non_stackable_type", "row" => 2, "column" => "T", "sheet_name" => "Sheet3" },
        { "value" => "PER_SHIPMENT", "header" => "rate_basis", "row" => 2, "column" => "E", "sheet_name" => "Sheet3" },
        { "value" => "truck_carriage", "header" => "mode_of_transport", "row" => 2, "column" => nil, "sheet_name" => "Sheet3" },
        { "value" => 0.28392e2, "header" => "rate", "row" => 6, "column" => "C", "sheet_name" => "Sheet3" },
        { "value" => "0.0", "header" => "row_minimum", "row" => 6, "column" => "B", "sheet_name" => "Sheet3" },
        { "value" => "1.0", "header" => "zone", "row" => 6, "column" => "A", "sheet_name" => "Sheet3" },
        { "value" => "0.0", "header" => "bracket_minimum", "row" => 5, "column" => "C", "sheet_name" => "Sheet3" },
        { "value" => "0.0 - 100.0", "header" => "brackets", "row" => 4, "column" => "C", "sheet_name" => "Sheet3" },
        { "value" => "kg", "header" => "modifiers", "row" => 3, "column" => "C", "sheet_name" => "Sheet3" },
        { "value" => 1, "header" => "hub_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet3" },
        { "value" => "organization-id", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet3" },
        { "value" => nil, "header" => "group_name", "row" => 2, "column" => nil, "sheet_name" => "Fees" },
        { "value" => nil, "header" => "group_id", "row" => 2, "column" => nil, "sheet_name" => "Fees" },
        { "value" => nil, "header" => "zone", "row" => 2, "column" => "T", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "service", "row" => 2, "column" => "V", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "carrier", "row" => 2, "column" => "U", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "carrier_code", "row" => 2, "column" => "U", "sheet_name" => "Fees" },
        { "value" => "export", "header" => "direction", "row" => 2, "column" => "E", "sheet_name" => "Fees" },
        { "value" => "default", "header" => "truck_type", "row" => 2, "column" => "D", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "cargo_class", "row" => 2, "column" => "W", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "min", "row" => 2, "column" => "O", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "max", "row" => 2, "column" => nil, "sheet_name" => "Fees" },
        { "value" => "Fuel Surcharge Fee", "header" => "fee_name", "row" => 2, "column" => "A", "sheet_name" => "Fees" },
        { "value" => "fsc", "header" => "fee_code", "row" => 2, "column" => "C", "sheet_name" => "Fees" },
        { "value" => "EUR", "header" => "currency", "row" => 2, "column" => "F", "sheet_name" => "Fees" },
        { "value" => "PER_SHIPMENT", "header" => "rate_basis", "row" => 2, "column" => "G", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "range_min", "row" => 2, "column" => "R", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "range_max", "row" => 2, "column" => "S", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "base", "row" => 2, "column" => nil, "sheet_name" => "Fees" },
        { "value" => nil, "header" => "ton", "row" => 2, "column" => "H", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "cbm", "row" => 2, "column" => "I", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "kg", "row" => 2, "column" => "J", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "item", "row" => 2, "column" => "K", "sheet_name" => "Fees" },
        { "value" => 0.3e2, "header" => "shipment", "row" => 2, "column" => "L", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "bill", "row" => 2, "column" => "M", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "container", "row" => 2, "column" => "N", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "wm", "row" => 2, "column" => "P", "sheet_name" => "Fees" },
        { "value" => nil, "header" => "percentage", "row" => 2, "column" => "Q", "sheet_name" => "Fees" },
        { "value" => "truck_carriage", "header" => "mode_of_transport", "row" => 2, "column" => nil, "sheet_name" => "Fees" },
        { "value" => 1, "header" => "hub_id", "row" => 0, "column" => 0, "sheet_name" => "Fees" },
        { "value" => "organization-id", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Fees" }
      ]
    end
    let(:expected_results) do
      Rover::DataFrame.new([
        { "zone" => "1.0",
          "range" => "20037 - 20039",
          "country_code" => "DE",
          "postal_code" => nil,
          "sheet_name" => "Sheet3",
          "row" => 0,
          "zone_row" => 6,
          "rate_row" => 6,
          "rate_column" => "C",
          "rate" => 28.392,
          "range_row" => 4,
          "range_column" => "C",
          "range_min" => 0.0,
          "range_max" => 100.0,
          "modifier_row" => 3,
          "modifier_column" => "C",
          "modifier" => "kg",
          "fee_code" => "trucking_lcl",
          "fee_name" => "Trucking rate",
          "rate_type" => "trucking_rate",
          "row_minimum_row" => 6,
          "row_minimum" => "0.0",
          "bracket_minimum_row" => 5,
          "bracket_minimum_column" => "C",
          "bracket_minimum" => "0.0",
          "column" => 0,
          "service" => "standard",
          "carrier" => "Gateway Cargo GmbH",
          "carrier_code" => "gateway cargo gmbh",
          "direction" => "export",
          "cargo_class" => "lcl",
          "load_type" => "cargo_item",
          "truck_type" => "default",
          "effective_date" => Date.parse("Tue, 01 Sep 2020"),
          "expiration_date" => Date.parse("Fri, 31 Dec 2021"),
          "cbm_ratio" => 250.0,
          "currency" => "EUR",
          "base" => 1.0,
          "load_meterage_stackable_limit" => 8.0,
          "load_meterage_non_stackable_limit" => 5.0,
          "load_meterage_hard_limit" => false,
          "load_meterage_stackable_type" => "area",
          "load_meterage_non_stackable_type" => "ldm",
          "rate_basis" => "PER_SHIPMENT",
          "group_name" => nil,
          "group_id" => nil,
          "min" => nil,
          "max" => nil,
          "mode_of_transport" => nil,
          "hub_id" => 1,
          "organization_id" => "organization-id",
          "identifier" => "postal_code" },
        { "zone" => nil,
          "range" => nil,
          "country_code" => nil,
          "postal_code" => nil,
          "sheet_name" => "Fees",
          "row" => 0,
          "zone_row" => nil,
          "rate_row" => nil,
          "rate_column" => nil,
          "rate" => 30.0,
          "range_row" => nil,
          "range_column" => nil,
          "range_min" => nil,
          "range_max" => nil,
          "modifier_row" => nil,
          "modifier_column" => nil,
          "modifier" => nil,
          "fee_code" => "fsc",
          "fee_name" => "Fuel Surcharge Fee",
          "rate_type" => "trucking_fee",
          "row_minimum_row" => nil,
          "row_minimum" => nil,
          "bracket_minimum_row" => nil,
          "bracket_minimum_column" => nil,
          "bracket_minimum" => nil,
          "column" => 0,
          "service" => nil,
          "carrier" => nil,
          "carrier_code" => nil,
          "direction" => "export",
          "cargo_class" => nil,
          "load_type" => nil,
          "truck_type" => "default",
          "effective_date" => nil,
          "expiration_date" => nil,
          "cbm_ratio" => nil,
          "currency" => "EUR",
          "base" => nil,
          "load_meterage_stackable_limit" => nil,
          "load_meterage_non_stackable_limit" => nil,
          "load_meterage_hard_limit" => nil,
          "load_meterage_stackable_type" => nil,
          "load_meterage_non_stackable_type" => nil,
          "rate_basis" => "PER_SHIPMENT",
          "group_name" => nil,
          "group_id" => nil,
          "min" => nil,
          "max" => nil,
          "mode_of_transport" => "truck_carriage",
          "hub_id" => 1,
          "organization_id" => "organization-id",
          "identifier" => "postal_code" }
      ])
    end

    it "returns a DataFrame of matrix values grouped into a table structure" do
      expect(result_frame).to match_array(expected_results)
    end

    # Using this as a way to gain coverage on DataFrame methods until rest of code is merged.
    it "returns rows with different sheet names" do
      expect(result_frame.group_by(["sheet_name"]).map { |rf| rf["sheet_name"].to_a }).to match_array([%w[Sheet3], %w[Fees]])
    end
  end
end
