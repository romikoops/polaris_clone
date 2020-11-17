# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Fees do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::Fees.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data, types: column_types) }
  let(:frame_data) do
    [
      {"fee" => "Fuel Surcharge Fee ",
       "mot" => "Ocean",
       "fee_code" => "fsc",
       "truck_type" => "Default",
       "direction" => "Export",
       "currency" => "eur",
       "rate_basis" => "per_shipment",
       "ton" => nil,
       "cbm" => nil,
       "kg" => nil,
       "item" => nil,
       "shipment" => "30.0",
       "bill" => nil,
       "container" => nil,
       "minimum" => nil,
       "wm" => nil,
       "percentage" => nil,
       "sheet_name" => "Fees"}
    ]
  end
  let(:result_frame) { Rover::DataFrame.new(expected_result, types: column_types) }

  describe ".sanitize" do
    let(:expected_result) do
      [{"fee" => "Fuel Surcharge Fee",
        "mot" => "ocean",
        "fee_code" => "FSC",
        "truck_type" => "default",
        "direction" => "export",
        "currency" => "EUR",
        "rate_basis" => "PER_SHIPMENT",
        "ton" => nil,
        "cbm" => nil,
        "kg" => nil,
        "item" => nil,
        "shipment" => 30.0,
        "bill" => nil,
        "container" => nil,
        "minimum" => nil,
        "wm" => nil,
        "percentage" => nil,
        "sheet_name" => "Fees"}]
    end

    it "returns the sanitized data" do
      expect(result.frame == result_frame).to be
    end
  end
end
