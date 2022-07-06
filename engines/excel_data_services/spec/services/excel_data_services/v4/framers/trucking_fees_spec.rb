# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Framers::TruckingFees do
  let(:result_frame) { described_class.new(frame: Rover::DataFrame.new(frame_data)).perform }

  describe "#perform" do
    let(:frame_data) do
      [
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
        { "value" => 3.0e1, "header" => "shipment", "row" => 2, "column" => "L", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "bill", "row" => 2, "column" => "M", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "container", "row" => 2, "column" => "N", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "wm", "row" => 2, "column" => "P", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => nil, "header" => "percentage", "row" => 2, "column" => "Q", "sheet_name" => "Fees", "target_frame" => "fees" },
        { "value" => "truck_carriage", "header" => "mode_of_transport", "row" => 2, "column" => nil, "sheet_name" => "Fees", "target_frame" => "fees" }
      ]
    end
    let(:expected_results) do
      Rover::DataFrame.new(
        [{
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
          "rate" => 3.0e1,
          "column" => nil,
          "target_frame" => "fees"
        }]
      )
    end

    it "returns a DataFrame of matrix values grouped into a table structure with all rate values under the header 'rate'" do
      expect(result_frame).to eq(expected_results)
    end
  end
end
