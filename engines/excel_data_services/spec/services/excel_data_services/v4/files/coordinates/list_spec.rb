# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Coordinates::List do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:coordinates) { "A,C" }
  let(:counterpart) { "1:1" }
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
      expect(result_coordinates).to eq([1, 3])
    end
  end
end
