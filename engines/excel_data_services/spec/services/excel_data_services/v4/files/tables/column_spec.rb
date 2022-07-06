# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::Column do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:xlsx) { Roo::ExcelxMoney.new(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:options) { { organization_id: organization.id } }
  let(:result_frame) { service.frame }
  let(:service) do
    described_class.new(
      xlsx: xlsx,
      header: header,
      sheet_name: sheet_name,
      options: ExcelDataServices::V4::Files::Tables::Options.new(options: options)
    )
  end
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    let(:column_results) do
      [{ "value" => "standard", "header" => "service", "row" => 2, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 3, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 4, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" },
        { "value" => "standard", "header" => "service", "row" => 5, "column" => "N", "sheet_name" => "Sheet1", "target_frame" => "default" }]
    end

    context "when column header is 'service'" do
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :tenant_vehicles, organization: organization, default_group: default_group) }
      let(:header) { "service" }
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          required: true,
          type: :object,
          alternative_keys: ["service_level"],
          fallback: "standard"
        }
      end

      it "returns a DataFrame of extracted values for the column in question" do
        expect(result_frame).to eq(Rover::DataFrame.new(column_results))
      end
    end

    context "when column header is 'service' column_index and column_length are provided" do
      let(:expected_results) { FactoryBot.build(:excel_data_services_section_data, :tenant_vehicles, organization: organization, default_group: default_group) }
      let(:header) { "service" }
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          required: true,
          type: :object,
          column_index: 14,
          column_length: 1,
          alternative_keys: ["service_level"],
          fallback: "standard"
        }
      end

      it "returns a DataFrame of extracted values for the column in question" do
        expect(result_frame).to eq(Rover::DataFrame.new(column_results[0]))
      end
    end

    context "when column header is 'destination_locode' and required data is missing" do
      let(:xlsx) { Roo::ExcelxMoney.new(file_fixture("excel/example_saco_pricings_errors.xlsx").to_s) }
      let(:header) { "destination_locode" }
      let(:options) do
        {
          sanitizer: "text",
          validator: "optional_string",
          required: true,
          type: :object
        }
      end
      let(:required_data_missing_error) { "Required data is missing at: (Sheet: Africa) row: 4 column: C. Please fill in the missing data and try again." }

      it "returns a DataFrame of extracted values for the column in question" do
        expect(service.errors.map(&:reason)).to include(required_data_missing_error)
      end
    end

    context "when column is configured to be unique and data is duplicated" do
      let(:xlsx) { Roo::ExcelxMoney.new(file_fixture("excel/example_saco_pricings_errors.xlsx").to_s) }
      let(:header) { "destination_locode" }
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          unique: true,
          type: :object
        }
      end
      let(:duplicate_data_error) { "Duplicates exists at (Sheet: Africa) row: 2 column: C & (Sheet: Africa) row: 3 column: C. Please remove all duplicate data and try again." }

      it "returns a DataFrame of extracted values for the column in question" do
        expect(service.errors.map(&:reason)).to include(duplicate_data_error)
      end
    end
  end

  describe "#rows" do
    let(:header) { "service" }

    it "returns the rows in the coordinate shorthand" do
      expect(service.rows).to eq("2:5")
    end
  end
end
