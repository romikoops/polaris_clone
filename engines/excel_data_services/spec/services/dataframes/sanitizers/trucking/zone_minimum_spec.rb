# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::ZoneMinimum do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:frame) { Rover::DataFrame.new(frame_data) }
  let(:frame_data) do
    [
      {"zone_minimum_row" => 5,
       "zone_minimum_col" => 3,
       "zone_minimum" => "0.0  ",
       "sheet_name" => "Sheet3"}
    ]
  end
  let(:result_frame) { Rover::DataFrame.new(expected_result) }

  describe ".sanitize" do
    context "when the value is a string" do
      let(:expected_result) do
        [{"zone_minimum_row" => 5,
          "zone_minimum_col" => 3,
          "zone_minimum" => 0.0,
          "sheet_name" => "Sheet3"}]
      end

      it "returns the sanitized data" do
        expect(result.frame == result_frame).to be
      end
    end
  end
end
