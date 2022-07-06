# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Framers::GrdbExcel do
  let(:result_frames) { described_class.new(section_parser: section_parser, state: state_arguments).perform }
  let(:result_frame) { result_frames["default"] }
  let(:state_arguments) { instance_double(ExcelDataServices::V4::State) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, headers: []) }
  let(:spreadsheet_cell_data) { instance_double(ExcelDataServices::V4::Files::SpreadsheetData, frame: Rover::DataFrame.new(frame_data), errors: errors) }
  let(:errors) { [] }

  before do
    allow(ExcelDataServices::V4::Files::SpreadsheetData).to receive(:new).with(section_parser: section_parser, state: state_arguments).and_return(spreadsheet_cell_data)
  end

  describe "#perform" do
    let(:frame_data) do
      [{ "value" => "standard", "header" => "service", "row" => 2, "column" => "N/A", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "WWA", "header" => "carrier", "row" => 2, "column" => "N/A", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "wwa", "header" => "carrier_code", "row" => 2, "column" => "N/A", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "P.E.T. MÜLHEIM", "header" => "customer", "row" => 2, "column" => "A", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "SSLL", "header" => "wwa_member", "row" => 2, "column" => "B", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "EMEA", "header" => "origin_region", "row" => 2, "column" => "C", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "DEHAM", "header" => "origin_inland_cfs", "row" => 2, "column" => "D", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "DEHAM", "header" => "consol_cfs", "row" => 2, "column" => "E", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "DEHAM", "header" => "origin_locode", "row" => 2, "column" => "F", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "JOAQJ", "header" => "transhipment_1", "row" => 2, "column" => "G", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "transhipment_2", "row" => 2, "column" => "H", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "transhipment_3", "row" => 2, "column" => "I", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "EMEA", "header" => "destination_region", "row" => 2, "column" => "J", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "JOAMM", "header" => "destination_locode", "row" => 2, "column" => "K", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "JOAMM", "header" => "deconsol_cfs", "row" => 2, "column" => "L", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "destination_inland_cfs", "row" => 2, "column" => "M", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "EMEA", "header" => "quoting_region", "row" => 2, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "EUR", "header" => "Dynamic(Sheet1-15):currency", "row" => 2, "column" => "O", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => 10, "header" => "Dynamic(Sheet1-16):container_loading", "row" => 2, "column" => "P", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "W/M", "header" => "Dynamic(Sheet1-17):rate_basis", "row" => 2, "column" => "Q", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-19):maximum", "row" => 2, "column" => "S", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-20):notes", "row" => 2, "column" => "T", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => Time.zone.today.to_date, "header" => "Dynamic(Sheet1-21):effective_date", "row" => 2, "column" => "U", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => 1.month.from_now.to_date, "header" => "Dynamic(Sheet1-22):expiration_date", "row" => 2, "column" => "V", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-23):currency", "row" => 2, "column" => "W", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-24):container_dray", "row" => 2, "column" => "X", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-25):rate_basis", "row" => 2, "column" => "Y", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-26):minimum", "row" => 2, "column" => "Z", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-27):maximum", "row" => 2, "column" => "AA", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-29):effective_date", "row" => 2, "column" => "AC", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-30):expiration_date", "row" => 2, "column" => "AD", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "USD", "header" => "Dynamic(Sheet1-31):currency", "row" => 2, "column" => "AE", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "on request", "header" => "Dynamic(Sheet1-32):ocean_freight", "row" => 2, "column" => "AF", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "WM", "header" => "Dynamic(Sheet1-33):rate_basis", "row" => 2, "column" => "AG", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-34):from", "row" => 2, "column" => "AH", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-35):to", "row" => 2, "column" => "AI", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "on request", "header" => "Dynamic(Sheet1-36):minimum", "row" => 2, "column" => "AJ", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-37):maximum", "row" => 2, "column" => "AK", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-38):effective_date", "row" => 2, "column" => "AL", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => nil, "header" => "Dynamic(Sheet1-39):expiration_date", "row" => 2, "column" => "AM", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "aaa-bbb-ccc-dddd", "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet1", "target_frame" => "default" }]
    end

    it "breaks each row on the currency key and return each section as its own row", :aggregate_failures do
      expect(result_frame["fee_code"].to_a).to eq(%w[container_loading container_dray ocean_freight])
      expect(result_frame["row"].to_a).to eq([2, 2, 2])
    end
  end
end
