# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::DataFrames::Validators::Trucking::Modifiers do
  let(:cell) do
    ExcelDataServices::DataFrames::DataProviders::Cell.new(
      value: modifier_value,
      label: header,
      sheet_name: "Sheet3",
      row: 1,
      col: 1
    )
  end
  let(:header) { "modifier" }
  let(:error) { described_class.validate(cell: cell, value: modifier_value, header: header) }

  describe ".validate" do
    it_behaves_like "modifier validator"
  end
end
