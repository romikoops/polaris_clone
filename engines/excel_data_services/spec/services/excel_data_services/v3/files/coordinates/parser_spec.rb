# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Coordinates::Parser do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_trucking.xlsx").to_s) }

  let(:result_coordinates) do
    described_class.new(
      sheet: xlsx.sheet("Zones"),
      coordinates: coordinates,
      axis: axis
    ).perform
  end

  describe "#perform" do
    context "when axis is columns" do
      let(:axis) { :column }

      context "when columns are defined in dynamic shorthand" do
        let(:coordinates) { "A:?" }

        it "returns the correct coordinates" do
          expect(result_coordinates).to eq(("A".."D").to_a)
        end
      end

      context "when columns are defined in range shorthand" do
        let(:coordinates) { "A:C" }

        it "returns the correct coordinates" do
          expect(result_coordinates).to eq(%w[A B C])
        end
      end

      context "when columns are not defined" do
        let(:coordinates) { nil }

        it "returns the correct coordinates" do
          expect(result_coordinates).to eq(["N/A"])
        end
      end
    end

    context "when axis is row" do
      let(:axis) { :row }

      context "when rows are defined in dynamic shorthand" do
        let(:coordinates) { "1:?" }

        it "returns the correct coordinates" do
          expect(result_coordinates).to eq([1, 2, 3])
        end
      end

      context "when rows are defined in range shorthand" do
        let(:coordinates) { "1:3" }

        it "returns the correct coordinates" do
          expect(result_coordinates).to eq([1, 2, 3])
        end
      end

      context "when rows are not defined" do
        let(:coordinates) { nil }

        it "returns the correct coordinates" do
          expect(result_coordinates).to eq(["N/A"])
        end
      end
    end
  end
end
