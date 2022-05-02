# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::SpreadsheetData do
  include_context "V4 setup"

  let(:service) { described_class.new(state: state_arguments, section_parser: section_parser) }
  let(:section_parser) { ExcelDataServices::V4::Files::SectionParser.new(section: section_string, state: state_arguments) }
  let(:xlsx) { File.open(file_fixture("excel/example_pricings_no_carrier.xlsx")) }

  describe "#frame" do
    let(:section_string) { "RoutingCarrier" }
    let(:expected_results) do
      [{ "value" => organization.slug,
         "header" => "carrier",
         "row" => 2,
         "column" => "M",
         "sheet_name" => "Sheet1" },
        { "value" => organization.slug,
          "header" => "carrier",
          "row" => 3,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => "MSC",
          "header" => "carrier",
          "row" => 4,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => "MSC",
          "header" => "carrier",
          "row" => 5,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => organization.slug.downcase,
          "header" => "carrier_code",
          "row" => 2,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => organization.slug.downcase,
          "header" => "carrier_code",
          "row" => 3,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => "msc",
          "header" => "carrier_code",
          "row" => 4,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => "msc",
          "header" => "carrier_code",
          "row" => 5,
          "column" => "M",
          "sheet_name" => "Sheet1" },
        { "value" => organization.id,
          "header" => "organization_id",
          "row" => 0,
          "column" => 0,
          "sheet_name" => "Sheet1" }]
    end

    it "returns a DataFrame of extracted values, with fallbacks" do
      expect(service.frame).to match_array(expected_results)
    end
  end
end
