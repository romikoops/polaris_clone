# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Framers::SacoImport do
  let(:result_frames) { described_class.new(section_parser: section_parser, state: state_arguments).perform }
  let(:result_frame) { result_frames["default"] }
  let(:state_arguments) { instance_double(ExcelDataServices::V4::State) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, headers: []) }
  let(:spreadsheet_cell_data) { instance_double(ExcelDataServices::V4::Files::SpreadsheetData, frame: Rover::DataFrame.new(frame_data), errors: errors) }
  let(:errors) { [] }

  before do
    allow(ExcelDataServices::V4::Files::SpreadsheetData).to receive(:new).with(section_parser: section_parser, state: state_arguments).and_return(spreadsheet_cell_data)
  end

  describe "#perform" do
    let(:frame_data) do
      [
        { "value" => "2022-04-01 - 2022-04-30", "header" => "period", "row" => 3, "column" => "A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "aaa-bbb-ccc-ddd", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => 0, "header" => "base", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "Saco Shipping", "header" => "carrier", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "saco_shipping", "header" => "carrier_code", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "ocean", "header" => "mode_of_transport", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "DEHAM", "header" => "destination_locode", "row" => 7, "column" => "A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "LATAM", "header" => "origin_region", "row" => 7, "column" => "B", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "EMEA", "header" => "destination_region", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "Buenos Aires", "header" => "origin_hub", "row" => 7, "column" => "D", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "ARBUE", "header" => "origin_locode", "row" => 7, "column" => "E", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "ARBUE", "header" => "currency", "row" => 7, "column" => "E", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => 218.0, "header" => "minimum", "row" => 7, "column" => "J", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => 218.0, "header" => "rate", "row" => 7, "column" => "H", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "pre_carriage_minimum", "row" => 7, "column" => "M", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "pre_carriage_rate", "row" => 7, "column" => "K", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "pre_carriage_basis", "row" => 7, "column" => "L", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "Surcharges", "header" => "remarks", "row" => 7, "column" => "O", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "transshipment", "row" => 7, "column" => "P", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "32.0", "header" => "transit_time", "row" => 7, "column" => "Q", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "PRIMARY_FREIGHT_CODE", "header" => "fee_code", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "effective_date", "row" => 7, "column" => "R", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "expiration_date", "row" => 7, "column" => "S", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "crl", "row" => 7, "column" => "T", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "New +", "header" => "rate_info", "row" => 7, "column" => "F", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "AR", "header" => "origin_country_code", "row" => 7, "column" => "C", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "group_id", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "group_name", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "lcl", "header" => "cargo_class", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "cargo_item", "header" => "load_type", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "range_min", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => nil, "header" => "range_max", "row" => 7, "column" => "N/A", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "W/M", "header" => "Dynamic(Tariff Sheet-9):basis", "row" => 7, "column" => "I", "sheet_name" => "Tariff Sheet", "target_frame" => "default" },
        { "value" => "Incl. CAF/BAF/OHC", "header" => "Dynamic(Tariff Sheet-14):basis", "row" => 7, "column" => "N", "sheet_name" => "Tariff Sheet", "target_frame" => "default" }
      ]
    end
    let(:expected_results) do
      Rover::DataFrame.new(
        [{ "base" => 0,
           "service" => "standard",
           "carrier" => "Saco Shipping",
           "carrier_code" => "saco_shipping",
           "mode_of_transport" => "ocean",
           "destination_locode" => "DEHAM",
           "origin_region" => "LATAM",
           "destination_region" => "EMEA",
           "origin_locode" => "ARBUE",
           "currency" => "ARBUE",
           "minimum" => 218.0,
           "rate" => 218.0,
           "pre_carriage_minimum" => nil,
           "pre_carriage_rate" => nil,
           "pre_carriage_basis" => nil,
           "remarks" => "Surcharges",
           "transshipment" => nil,
           "transit_time" => "32.0",
           "fee_code" => "PRIMARY_FREIGHT_CODE",
           "effective_date" => Date.parse("Fri, 01 Apr 2022"),
           "expiration_date" => Date.parse("Sat, 30 Apr 2022"),
           "crl" => nil,
           "rate_info" => "New +",
           "origin_country_code" => "AR",
           "group_id" => nil,
           "group_name" => nil,
           "cargo_class" => "lcl",
           "load_type" => "cargo_item",
           "range_min" => nil,
           "range_max" => nil,
           "Dynamic(Tariff Sheet-9):basis" => "W/M",
           "Dynamic(Tariff Sheet-14):basis" => "Incl. CAF/BAF/OHC",
           "sheet_name" => "Tariff Sheet",
           "organization_id" => "aaa-bbb-ccc-ddd",
           "row" => 7,
           "target_frame" => "default" }]
      )
    end

    it "returns a DataFrame of the SacoImport cell values grouped into a table structure" do
      expect(result_frame).to eq(expected_results)
    end

    it "finds and splits the period into effective_date and expiration_date", :aggregate_failures do
      expect(result_frame["effective_date"].to_a).to eq([Date.parse("Fri, 01 Apr 2022")])
      expect(result_frame["expiration_date"].to_a).to eq([Date.parse("Sat, 30 Apr 2022")])
    end
  end
end
