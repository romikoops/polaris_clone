# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Coordinates::Relative do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:coordinates) { "A:counterpart.last_col" }
  let(:counterpart) { "1:3" }
  let(:axis) { "cols" }
  let(:result_coordinates) do
    described_class.new(
      sheet: xlsx.sheet(xlsx.sheets.first),
      coordinates: coordinates,
      counterpart: counterpart,
      axis: axis
    ).perform
  end

  describe "#perform" do
    it "returns successfully" do
      expect(result_coordinates).to eq(1.upto(xlsx.row(1).compact.count).to_a)
    end
  end
end
