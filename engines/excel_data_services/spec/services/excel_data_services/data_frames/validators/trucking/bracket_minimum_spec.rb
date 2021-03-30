# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::BracketMinimum do
  let(:cell) do
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: rate_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  end
  let(:header) { "bracket_minimum" }
  let(:error) { described_class.validate(cell: cell, value: rate_value, header: header) }

  describe ".validate" do
    it_behaves_like "numeric validator"
  end
end
