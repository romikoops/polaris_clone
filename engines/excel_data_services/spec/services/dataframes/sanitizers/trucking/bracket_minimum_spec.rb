# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::BracketMinimum do
  include_context "with standard trucking setup"

  let(:frame) { Rover::DataFrame.new(frame_data) }
  let(:frame_data) do
    [
      {"bracket_minimum_row" => 5,
       "bracket_minimum_col" => 3,
       "bracket_minimum" => "0.0  ",
       "sheet_name" => "Sheet3"}
    ]
  end
  let(:result_frame) { Rover::DataFrame.new(expected_result) }
  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }

  describe ".sanitize" do
    context "when the value is a string" do
      let(:expected_result) do
        [{"bracket_minimum_row" => 5,
          "bracket_minimum_col" => 3,
          "bracket_minimum" => 0.0,
          "sheet_name" => "Sheet3"}]
      end

      it "returns the sanitized data", :aggregate_failures do
        expect(result.frame == result_frame).to be
      end
    end
  end
end
