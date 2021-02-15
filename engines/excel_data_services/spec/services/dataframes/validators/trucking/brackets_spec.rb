# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Brackets do
  let(:cell) {
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  }
  let(:header) { "bracket" }
  let(:error) { described_class.validate(cell: cell, value: value, header: header) }

  describe ".validate" do
    it_behaves_like "bracket validator"
  end
end
