# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::Sheet do
  include_context "V4 setup"

  let(:column) do
    instance_double(ExcelDataServices::V4::Files::Tables::Column,
      present_on_sheet?: true,
      valid?: true,
      header: "header_a",
      sheet_name: "Sheet1",
      sheet_column: 1,
      frame: Rover::DataFrame.new([{ "value" => "a", "header" => "header_a", "row" => 1, "column" => "A", "sheet_name" => "Sheet1" }]))
  end
  let(:matrix) do
    instance_double(ExcelDataServices::V4::Files::Tables::Matrix,
      present_on_sheet?: true,
      valid?: true,
      header: "header_b",
      sheet_name: "Sheet1",
      frame: Rover::DataFrame.new([{ "value" => "b", "header" => "header_b", "row" => 1, "column" => "B", "sheet_name" => "Sheet1" }]))
  end
  let(:dynamic_column) { instance_double(ExcelDataServices::V4::Files::Tables::DynamicColumns) }
  let(:dynamically_generated_column) do
    instance_double(ExcelDataServices::V4::Files::Tables::Column,
      present_on_sheet?: true,
      valid?: true,
      header: "Dynamic:header_c",
      sheet_name: "Sheet1",
      sheet_column: 3,
      frame: Rover::DataFrame.new([{ "value" => "c", "header" => "Dynamic:header_c", "row" => 1, "column" => "C", "sheet_name" => "Sheet1" }]))
  end
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, columns: [column], matrixes: [matrix], dynamic_columns: [dynamic_column]) }
  let(:service) { described_class.new(sheet_name: "Sheet1", section_parser: section_parser, state: state_arguments) }
  let(:arguments) { {} }

  before do
    allow(dynamic_column).to receive(:columns).and_return(dynamically_generated_column)
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    context "with invalid columns and matrixes" do
      let(:column) do
        instance_double(ExcelDataServices::V4::Files::Tables::Column,
          present_on_sheet?: true,
          valid?: false,
          header: "header_a",
          sheet_name: "Sheet1",
          sheet_column: 1)
      end
      let(:matrix) do
        instance_double(ExcelDataServices::V4::Files::Tables::Matrix,
          present_on_sheet?: true,
          valid?: false,
          header: "header_b",
          sheet_name: "Sheet1")
      end

      it "returns an empty DataFrame" do
        expect(service.perform).to eq(Rover::DataFrame.new)
      end
    end

    context "with columns, matrix and dynamic columns" do
      let(:concatenated_frame) do
        Rover::DataFrame.new([
          { "value" => "a", "header" => "header_a", "row" => 1, "column" => "A", "sheet_name" => "Sheet1" },
          { "value" => "b", "header" => "header_b", "row" => 1, "column" => "B", "sheet_name" => "Sheet1" },
          { "value" => "c", "header" => "Dynamic:header_c", "row" => 1, "column" => "C", "sheet_name" => "Sheet1" },
          { "value" => organization.id, "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet1" }
        ])
      end

      it "returns the data from the matrix, column and dynamic columns concatenated together" do
        expect(service.perform).to eq(concatenated_frame)
      end
    end

    context "when one of the data sources doesnt amtch the sheet" do
      let(:matrix) do
        instance_double(ExcelDataServices::V4::Files::Tables::Matrix,
          present_on_sheet?: true,
          valid?: true,
          header: "header_b",
          sheet_name: "Sheet2",
          frame: Rover::DataFrame.new([{ "value" => "b", "header" => "header_b", "row" => 1, "column" => "B", "sheet_name" => "Sheet1" }]))
      end
      let(:concatenated_frame) do
        Rover::DataFrame.new([
          { "value" => "a", "header" => "header_a", "row" => 1, "column" => "A", "sheet_name" => "Sheet1" },
          { "value" => "c", "header" => "Dynamic:header_c", "row" => 1, "column" => "C", "sheet_name" => "Sheet1" },
          { "value" => organization.id, "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "Sheet1" }
        ])
      end

      it "returns the data from the matrix, column and dynamic columns concatenated together" do
        expect(service.perform).to eq(concatenated_frame)
      end
    end
  end
end
