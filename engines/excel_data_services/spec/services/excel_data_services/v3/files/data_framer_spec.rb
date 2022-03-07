# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::DataFramer do
  include_context "V3 setup"

  let(:service) { described_class.new(state: state_arguments, sheet_parser: sheet_parser) }
  let(:sheet_parser) { ExcelDataServices::V3::Files::SheetParser.new(type: "section", section: section_string, state: state_arguments) }
  let(:result_state) { service.perform }

  describe "#perform" do
    let(:spreadsheet_frame) do
      Rover::DataFrame.new([
        { "value" => "a", "header" => "header_a", "row" => 1, "column" => "A", "sheet_name" => "Sheet1" },
        { "value" => "b", "header" => "header_b", "row" => 1, "column" => "B", "sheet_name" => "Sheet1" },
        { "value" => "a2", "header" => "header_a", "row" => 2, "column" => "A", "sheet_name" => "Sheet1" },
        { "value" => "b2", "header" => "header_b", "row" => 2, "column" => "B", "sheet_name" => "Sheet1" }
      ])
    end
    let(:expected_frame) do
      Rover::DataFrame.new({
        "header_a" => %w[a a2],
        "header_b" => %w[b b2],
        "sheet_name" => ["Sheet1"] * 2,
        "row" => [1, 2]
      })
    end
    let(:errors) { [] }
    let(:spreadsheet_cell_data_double) { instance_double(ExcelDataServices::V3::Files::SpreadsheetData, frame: spreadsheet_frame, errors: errors) }

    before do
      allow(service).to receive(:spreadsheet_cell_data).and_return(spreadsheet_cell_data_double)
    end

    it "returns the cell data in denormalized form" do
      expect(result_state.frame).to eq(expected_frame)
    end

    context "when there are errors on the spreadsheet" do
      let(:errors) { ["x"] }

      it "appends the errors to state" do
        expect(result_state.errors).to eq(errors)
      end
    end
  end
end
