# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Files::Tables::Column do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_pricings.xlsx").to_s) }
  let(:sheet_name) { xlsx.sheets.first }
  let(:options) { { organization_id: organization.id } }
  let(:result_frame) { service.frame }
  let(:service) do
    described_class.new(
      xlsx: xlsx,
      header: header,
      sheet_name: sheet_name,
      options: options
    )
  end
  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe "#perform" do
    let(:column_results) do
      [{ "service" => "standard", "row" => 2, "sheet_name" => "Sheet1" },
        { "service" => "standard", "row" => 3, "sheet_name" => "Sheet1" },
        { "service" => "standard", "row" => 4, "sheet_name" => "Sheet1" },
        { "service" => "standard", "row" => 5, "sheet_name" => "Sheet1" }]
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

    context "when column header is 'destination_locode' and required data is missing" do
      let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_saco_pricings_errors.xlsx").to_s) }
      let(:header) { "destination_locode" }
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          required: true,
          type: :object
        }
      end
      let(:required_data_missing_error) { "Required data is missing in column: destination_locode. Please fill in the missing data and try again." }

      it "returns a DataFrame of extracted values for the column in question" do
        expect(service.errors.map(&:reason)).to include(required_data_missing_error)
      end
    end

    context "when column is configured to be unique and data is duplicated" do
      let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_saco_pricings_errors.xlsx").to_s) }
      let(:header) { "destination_locode" }
      let(:options) do
        {
          sanitizer: "text",
          validator: "string",
          unique: true,
          type: :object
        }
      end
      let(:duplicate_data_error) { "Duplicates exists in column: #{header}. Please remove all duplicate data and try again." }

      it "returns a DataFrame of extracted values for the column in question" do
        expect(service.errors.map(&:reason)).to include(duplicate_data_error)
      end
    end
  end
end
