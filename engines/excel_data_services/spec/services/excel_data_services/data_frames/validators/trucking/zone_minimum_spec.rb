# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::ZoneMinimum do
  let(:cell) do
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: optional_numeric_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  end
  let(:header) { "zone_minimum" }
  let(:error) { described_class.validate(cell: cell, value: optional_numeric_value, header: header) }

  describe ".validate" do
    it_behaves_like "optional_numeric validator"
  end
end
