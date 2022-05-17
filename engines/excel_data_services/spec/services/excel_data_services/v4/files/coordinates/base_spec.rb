# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Coordinates::Base do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:coordinates) { "A:?" }
  let(:counterpart) { "1:1" }
  let(:axis) { "cols" }
  let(:result_coordinates) do
    described_class.extract(
      sheet: xlsx.sheet(xlsx.sheets.first),
      coordinates: coordinates,
      counterpart: counterpart,
      axis: axis
    )
  end

  describe "self.extract" do
    context "when section is dynamic" do
      it "returns the correct coordinates" do
        expect(result_coordinates).to eq([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25])
      end
    end
  end
end
