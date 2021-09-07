# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Files::Tables::Column do
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
      [{ "service" => "standard", "row" => 1, "sheet_name" => "Sheet1" },
        { "service" => "standard", "row" => 2, "sheet_name" => "Sheet1" },
        { "service" => "standard", "row" => 3, "sheet_name" => "Sheet1" },
        { "service" => "standard", "row" => 4, "sheet_name" => "Sheet1" }]
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
  end
end
