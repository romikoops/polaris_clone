# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Sanitizers::Trucking::Values do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:frame) { Rover::DataFrame.new(frame_data) }
  let(:frame_data) do
    [
      {"value_row" => 4,
       "value_col" => 3,
       "value" => "100.0 ",
       "sheet_name" => "Sheet3"}
    ]
  end
  let(:result_frame) { Rover::DataFrame.new(expected_result) }

  describe ".sanitize" do
    context "when the value is a string" do
      let(:expected_result) do
        [{"value_row" => 4,
          "value_col" => 3,
          "value" => 100.0,
          "sheet_name" => "Sheet3"}]
      end

      it "returns the sanitized data" do
        expect(result.frame.to_a.first).to eq(result_frame.to_a.first)
      end
    end
  end
end
