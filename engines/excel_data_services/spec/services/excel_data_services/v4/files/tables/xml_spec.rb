# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::Xml do
  include_context "V4 setup"

  let(:service) { described_class.new(section_parser: section_parser, state: state_arguments) }
  let(:section_parser) { instance_double(ExcelDataServices::V4::Files::SectionParser, xml_data: xml_data, xml_columns: [column, identifier_column]) }
  let(:xml_data) { instance_double("XmlData", identifier_key: "HeaderB", identifiers: ["b"]) }
  let(:column) do
    instance_double(ExcelDataServices::V4::Files::Tables::XmlColumn,
      valid?: true,
      header: "header_a",
      errors: [],
      frame: Rover::DataFrame.new([{ "value" => "a", "header" => "header_a", "row" => 1, "column" => "header_a", "sheet_name" => "b" }]))
  end
  let(:identifier_column) do
    instance_double(ExcelDataServices::V4::Files::Tables::XmlColumn,
      valid?: true,
      header: "header_b",
      errors: [],
      frame: Rover::DataFrame.new([{ "value" => "b", "header" => "header_b", "row" => 1, "column" => "header_b", "sheet_name" => "b" }]))
  end

  describe "#frame" do
    let(:result) { service.frame }
    let(:expected_result) do
      Rover::DataFrame.new([
        { "value" => organization.id, "header" => "organization_id", "row" => 0, "column" => 0, "sheet_name" => "b" },
        { "value" => "a", "header" => "header_a", "row" => 1, "column" => "header_a", "sheet_name" => "b" },
        { "value" => "b", "header" => "header_b", "row" => 1, "column" => "header_b", "sheet_name" => "b" }
      ])
    end

    it "returns the two values combined together into a DataFrame with the 'identifier_key' value used as sheet_name" do
      expect(result).to eq(expected_result)
    end

    context "when there are errors" do
      let(:column) do
        instance_double(ExcelDataServices::V4::Files::Tables::XmlColumn,
          valid?: false,
          header: "header_a",
          frame: Rover::DataFrame.new([{ "value" => "a", "header" => "header_a", "row" => 1, "column" => "header_a", "sheet_name" => "Sheet1" }]),
          errors: ["error"])
      end

      it "returns the errors" do
        expect(service.errors).to eq(["error"])
      end
    end
  end
end
