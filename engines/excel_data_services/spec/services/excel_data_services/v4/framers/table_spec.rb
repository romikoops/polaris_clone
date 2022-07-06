# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Framers::Table do
  let(:result_frames) { described_class.new(section_parser: section_parser, state: state_arguments).perform }
  let(:result_frame) { result_frames["default"] }
  let(:state_arguments) { instance_double(ExcelDataServices::V4::State) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, headers: %w[a b]) }
  let(:spreadsheet_cell_data) { instance_double(ExcelDataServices::V4::Files::SpreadsheetData, frame: Rover::DataFrame.new(frame_data), errors: errors) }
  let(:errors) { [] }

  before do
    allow(ExcelDataServices::V4::Files::SpreadsheetData).to receive(:new).with(section_parser: section_parser, state: state_arguments).and_return(spreadsheet_cell_data)
  end

  describe "#perform" do
    let(:frame_data) do
      [
        { "header" => "a", "value" => 1, "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 1, "column" => "A" },
        { "header" => "a", "value" => 2, "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 2, "column" => "A" },
        { "header" => "a", "value" => 3, "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 3, "column" => "A" },
        { "header" => "b", "value" => 10, "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 1, "column" => "B" },
        { "header" => "b", "value" => 11, "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 2, "column" => "B" },
        { "header" => "b", "value" => 12, "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 3, "column" => "B" },
        { "header" => "organization_id", "value" => "aaa-bbb-ccc-ddd", "target_frame" => "default", "sheet_name" => "Sheet1", "row" => 0, "column" => "" }
      ]
    end
    let(:expected_results) do
      Rover::DataFrame.new([
        { "a" => 1, "b" => 10, "sheet_name" => "Sheet1", "organization_id" => "aaa-bbb-ccc-ddd", "row" => 1, "target_frame" => "default" },
        { "a" => 2, "b" => 11, "sheet_name" => "Sheet1", "organization_id" => "aaa-bbb-ccc-ddd", "row" => 2, "target_frame" => "default" },
        { "a" => 3, "b" => 12, "sheet_name" => "Sheet1", "organization_id" => "aaa-bbb-ccc-ddd", "row" => 3, "target_frame" => "default" }
      ])
    end

    it "returns a DataFrame of matrix values grouped into a table structure" do
      expect(result_frame).to eq(expected_results)
    end
  end
end
