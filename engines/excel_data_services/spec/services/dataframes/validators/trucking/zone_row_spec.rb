# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::ZoneRow do
  let(:cell) {
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: zone_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  }
  let(:header) { "zone" }
  let(:error) { described_class.validate(cell: cell, value: zone_value, header: header) }

  describe ".validate" do
    it_behaves_like "zone validator"
  end
end
