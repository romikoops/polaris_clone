# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Coordinates::Parser do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_trucking.xlsx").to_s) }

  let(:parsed_coordinates) do
    described_class.new(
      sheet: xlsx.sheet("Zones"),
      input_rows: input_rows,
      input_columns: input_columns
    )
  end

  describe "#columns" do
    let(:input_rows) { "1:?" }

    context "when columns are defined in dynamic shorthand" do
      let(:input_columns) { "A:?" }

      it "returns the correct coordinates" do
        expect(parsed_coordinates.columns).to eq(("A".."D").to_a)
      end
    end

    context "when columns are defined in range shorthand" do
      let(:input_columns) { "A:C" }

      it "returns the correct coordinates" do
        expect(parsed_coordinates.columns).to eq(%w[A B C])
      end
    end

    context "when columns are not defined" do
      let(:input_columns) { nil }

      it "returns the correct coordinates" do
        expect(parsed_coordinates.columns).to eq(["N/A"])
      end
    end
  end

  describe "#rows" do
    let(:input_columns) { "A:D" }

    context "when rows are defined in dynamic shorthand" do
      let(:input_rows) { "1:?" }

      it "returns the correct coordinates" do
        expect(parsed_coordinates.rows).to eq([1, 2, 3])
      end
    end

    context "when rows are defined in range shorthand" do
      let(:input_rows) { "1:3" }

      it "returns the correct coordinates" do
        expect(parsed_coordinates.rows).to eq([1, 2, 3])
      end
    end

    context "when rows are not defined" do
      let(:input_rows) { nil }

      it "returns the correct coordinates" do
        expect(parsed_coordinates.rows).to eq(["N/A"])
      end
    end
  end
end
