# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::ZoneRow do
  include_context "with standard trucking setup"

  let(:target_schema) { nil }
  let(:result) { described_class.state(state: combinator_arguments) }
  let(:column_types) { ExcelDataServices::DataFrames::DataProviders::Trucking::ZoneRow.column_types }
  let(:frame) { Rover::DataFrame.new(frame_data, types: column_types) }
  let(:frame_data) do
    [
      {"zone_row" => 4,
       "zone_col" => 3,
       "zone" => zone_value,
       "sheet_name" => "Sheet3"}
    ]
  end

  let(:errors) { result.errors }

  describe ".validate" do
    it_behaves_like "zone validator"
  end
end
