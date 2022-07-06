# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::Matrix do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:xlsx) { Roo::ExcelxMoney.new(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:result_frame) { service.frame }
  let(:service) do
    described_class.new(
      xlsx: xlsx,
      header: "service",
      rows: rows,
      columns: columns,
      sheet_name: sheet_name,
      options: ExcelDataServices::V4::Files::Tables::Options.new(options: options)
    )
  end

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    let(:matrix_results) do
      [{ "value" => "standard", "header" => "service", "row" => 2, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 3, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 4, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 5, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" }]
    end
    let(:options) do
      {
        sanitizer: "text",
        validator: "string",
        required: true,
        type: :object,
        fallback: "standard"
      }
    end
    let(:rows) { "2:?" }
    let(:columns) { "N" }

    context "when column header is 'service'" do
      it "returns a DataFrame of extracted values for the defined area", :aggregate_failures do
        expect(service).to be_valid
        expect(result_frame).to eq(Rover::DataFrame.new(matrix_results))
      end
    end

    context "when column argument is invalid" do
      let(:columns) { xlsx }

      it "raises and argument error" do
        expect { service.columns }.to raise_error(ArgumentError)
      end
    end

    context "when required data is missing" do
      let(:columns) { "Z" }
      let(:rows) { "2:3" }
      let(:required_data_missing_error) { "Required data is missing at: (Sheet: Sheet1) row: 2 column: Z. Please fill in the missing data and try again." }
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          required: true,
          type: :object
        }
      end

      it "returns errors specifying the missing data's location" do
        expect(service.errors.map(&:reason)).to include(required_data_missing_error)
      end
    end

    context "when data is configured to be unique and data is duplicated" do
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          unique: true,
          type: :object
        }
      end
      let(:duplicate_data_error) do
        "Duplicates exists at (Sheet: Sheet1) row: 2 column: N & (Sheet: Sheet1) row: 3 column: N & (Sheet: Sheet1) row: 4 column: N & (Sheet: Sheet1) row: 5 column: N. Please remove all duplicate data and try again."
      end

      it "returns errors specifying the duplicated data's location" do
        expect(service.errors.map(&:reason)).to include(duplicate_data_error)
      end
    end
  end
end
