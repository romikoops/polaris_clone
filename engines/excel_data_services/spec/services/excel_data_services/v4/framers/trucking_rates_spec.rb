# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Framers::TruckingRates do
  let(:result_frame) { described_class.new(section_parser: section_parser, state: state_arguments).perform }
  let(:state_arguments) { instance_double(ExcelDataServices::V4::State) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser) }
  let(:spreadsheet_cell_data) { instance_double(ExcelDataServices::V4::Files::SpreadsheetData, frame: Rover::DataFrame.new(frame_data), errors: errors) }
  let(:errors) { [] }

  before do
    allow(ExcelDataServices::V4::Files::SpreadsheetData).to receive(:new).with(section_parser: section_parser, state: state_arguments).and_return(spreadsheet_cell_data)
  end

  describe "#perform" do
    let(:frame_data) do
      [
        { "value" => "postal_code", "header" => "identifier", "row" => 1, "column" => "B", "sheet_name" => "Zones", "target_frame" => "zones" },
        { "value" => "1.0", "header" => "zone", "row" => 2, "column" => "A", "sheet_name" => "Zones", "target_frame" => "zones" },
        secondary_cell_data,
        { "value" => "DE", "header" => "country_code", "row" => 2, "column" => "D", "sheet_name" => "Zones", "target_frame" => "zones" },
        { "value" => nil, "header" => "postal_code", "row" => 2, "column" => "B", "sheet_name" => "Zones", "target_frame" => "zones" },
        { "value" => "organization-id", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Zones", "target_frame" => "rates" },
        { "value" => "standard", "header" => "service", "row" => 2, "column" => "L", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "Gateway Cargo GmbH", "header" => "carrier", "row" => 2, "column" => "K", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "gateway cargo gmbh", "header" => "carrier_code", "row" => 2, "column" => "K", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "export", "header" => "direction", "row" => 2, "column" => "J", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "lcl", "header" => "cargo_class", "row" => 2, "column" => "I", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "cargo_item", "header" => "load_type", "row" => 2, "column" => "H", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "default", "header" => "truck_type", "row" => 2, "column" => "G", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => Date.parse("Tue, 01 Sep 2020"), "header" => "effective_date", "row" => 2, "column" => "M", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => Date.parse("Fri, 31 Dec 2021"), "header" => "expiration_date", "row" => 2, "column" => "N", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => 250.0, "header" => "cbm_ratio", "row" => 2, "column" => "C", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "EUR", "header" => "currency", "row" => 2, "column" => "B", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => 1.0, "header" => "base", "row" => 2, "column" => "F", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => 8.0, "header" => "load_meterage_stackable_limit", "row" => 2, "column" => "P", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => 5.0, "header" => "load_meterage_non_stackable_limit", "row" => 2, "column" => "Q", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => false, "header" => "load_meterage_hard_limit", "row" => 2, "column" => "R", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "area", "header" => "load_meterage_stackable_type", "row" => 2, "column" => "S", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "ldm", "header" => "load_meterage_non_stackable_type", "row" => 2, "column" => "T", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "PER_SHIPMENT", "header" => "rate_basis", "row" => 2, "column" => "E", "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => "truck_carriage", "header" => "mode_of_transport", "row" => 2, "column" => nil, "sheet_name" => "Sheet3", "target_frame" => "default" },
        { "value" => 283.92, "header" => "rate", "row" => 6, "column" => "C", "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => "0.0", "header" => "row_minimum", "row" => 6, "column" => "B", "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => "1.0", "header" => "zone", "row" => 6, "column" => "A", "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => "0.0", "header" => "bracket_minimum", "row" => 5, "column" => "C", "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => "0.0 - 100.0", "header" => "bracket", "row" => 4, "column" => "C", "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => "kg", "header" => "modifier", "row" => 3, "column" => "C", "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => 1, "header" => "hub_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => "organization-id", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet3", "target_frame" => "rates" },
        { "value" => nil, "header" => "group_name", "row" => 2, "column" => nil, "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "group_id", "row" => 2, "column" => nil, "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "zone", "row" => 2, "column" => "T", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "service", "row" => 2, "column" => "V", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "carrier", "row" => 2, "column" => "U", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "carrier_code", "row" => 2, "column" => "U", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "export", "header" => "direction", "row" => 2, "column" => "E", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "default", "header" => "truck_type", "row" => 2, "column" => "D", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "cargo_class", "row" => 2, "column" => "W", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "min", "row" => 2, "column" => "O", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "max", "row" => 2, "column" => nil, "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "Fuel Surcharge Fee", "header" => "fee_name", "row" => 2, "column" => "A", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "fsc", "header" => "fee_code", "row" => 2, "column" => "C", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "EUR", "header" => "currency", "row" => 2, "column" => "F", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "PER_SHIPMENT", "header" => "rate_basis", "row" => 2, "column" => "G", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "range_min", "row" => 2, "column" => "R", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "range_max", "row" => 2, "column" => "S", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "base", "row" => 2, "column" => nil, "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "ton", "row" => 2, "column" => "H", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "cbm", "row" => 2, "column" => "I", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "kg", "row" => 2, "column" => "J", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "item", "row" => 2, "column" => "K", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => 30.0, "header" => "shipment", "row" => 2, "column" => "L", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "bill", "row" => 2, "column" => "M", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "container", "row" => 2, "column" => "N", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "wm", "row" => 2, "column" => "P", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "percentage", "row" => 2, "column" => "Q", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "truck_carriage", "header" => "mode_of_transport", "row" => 2, "column" => nil, "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => 1, "header" => "hub_id", "row" => 0, "column" => 0, "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "organization-id", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Fees", "target_frame" => "fees" }
      ]
    end
    let(:expected_default) do
      Rover::DataFrame.new(
        [{ "row" => 2,
           "column" => nil,
           "sheet_name" => "Sheet3",
           "target_frame" => "default",
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
           "mode_of_transport" => "truck_carriage",
           "organization_id" => "organization-id",
           "hub_id" => 1,
           "group_id" => nil }]
      )
    end
    let(:expected_fees) do
      Rover::DataFrame.new([{
        "rate_type" => "trucking_fee",
        "mode_of_transport" => "truck_carriage",
        "row" => 2,
        "sheet_name" => "Fees",
        "group_name" => nil,
        "group_id" => nil,
        "zone" => nil,
        "service" => nil,
        "carrier" => nil,
        "carrier_code" => nil,
        "direction" => "export",
        "truck_type" => "default",
        "cargo_class" => nil,
        "min" => nil,
        "max" => nil,
        "fee_name" => "Fuel Surcharge Fee",
        "fee_code" => "fsc",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "range_min" => nil,
        "range_max" => nil,
        "base" => nil,
        "rate" => 30.0,
        "column" => nil,
        "target_frame" => "fees",
        "organization_id" => "organization-id",
        "hub_id" => 1
      }])
    end
    let(:expected_rates) do
      Rover::DataFrame.new([{
        "sheet_name" => "Sheet3",
        "target_frame" => "default",
        "rate" => 283.92,
        "range_min" => 0.0,
        "range_max" => 100.0,
        "modifier" => "kg",
        "fee_code" => "trucking_lcl",
        "fee_name" => "Trucking rate",
        "rate_type" => "trucking_rate",
        "mode_of_transport" => "truck_carriage",
        "row_minimum" => "0.0",
        "bracket_minimum" => "0.0",
        "zone" => "1.0",
        "organization_id" => "organization-id",
        "hub_id" => 1,
        "group_id" => nil,
        "rate_basis" => "PER_SHIPMENT",
        "row" => 6
      }])
    end
    let(:expected_zones) do
      Rover::DataFrame.new([{
        "sheet_name" => "Zones",
        "row" => 2,
        "target_frame" => "zones",
        "zone" => "1.0",
        "range" => "20037 - 20039",
        "country_code" => "DE",
        "postal_code" => nil,
        "organization_id" => "organization-id",
        "hub_id" => nil,
        "group_id" => nil,
        "identifier" => "postal_code"
      }])
    end
    let(:expected_frames) do
      {
        "rates" => expected_rates,
        "zones" => expected_zones,
        "fees" => expected_fees,
        "default" => expected_default
      }
    end
    let(:secondary_cell_data) { { "value" => "20037 - 20039", "header" => "range", "row" => 2, "column" => "C", "sheet_name" => "Zones", "target_frame" => "zones" } }

    it "returns a DataFrame of matrix values grouped into a table structure and divided amongst fees, rates, zones and default" do
      expect(result_frame).to match_array(expected_frames)
    end

    context "when it is a postal_city sheet" do
      let(:secondary_cell_data) { { "value" => "Hamburg", "header" => "city", "row" => 2, "column" => "C", "sheet_name" => "Zones" } }

      it "returns the identifier as postal_city" do
        expect(result_frame["zones"]["identifier"].to_a).to eq(["postal_city"])
      end
    end
  end
end
