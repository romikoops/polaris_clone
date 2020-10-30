# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::ZoneMinimum do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneMinimum.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data) }
  let(:frame_data) do
    [
      {"zone_minimum_row" => 4,
       "zone_minimum_col" => 3,
       "zone_minimum" => optional_numeric_value,
       "sheet_name" => "Sheet3"}
    ]
  end

  let(:errors) { result.errors }

  describe ".validate" do
    it_behaves_like "optional_numeric validator"
  end
end
