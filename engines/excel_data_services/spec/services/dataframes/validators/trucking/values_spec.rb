# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Values do
  let(:cell) {
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: rate_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  }
  let(:header) { "value" }
  let(:error) { described_class.validate(cell: cell, value: rate_value, header: header) }
  describe ".validate" do
    it_behaves_like "numeric validator"
  end
end
