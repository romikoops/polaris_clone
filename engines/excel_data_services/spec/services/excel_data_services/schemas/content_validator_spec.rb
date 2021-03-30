# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::ContentValidator do
  include_context "with real trucking_sheet"

  let(:result) { described_class.valid?(source: source, section: section) }

  describe ".valid?" do
    let(:section) { "headers" }

    context "with a valid rates sheet" do
      let(:section) { "metadata_headers" }
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }

      it "returns successfully" do
        expect(result).to be_truthy
      end
    end

    context "with a valid zones sheet" do
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_zones, file: xlsx, sheet_name: "Zones") }

      it "returns successfully" do
        expect(result).to be_truthy
      end
    end

    context "with a valid fees sheet" do
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_fees, file: xlsx, sheet_name: "Fees") }

      it "returns successfully" do
        expect(result).to be_truthy
      end
    end

    context "with an invalid sheet" do
      let(:xlsx) { Roo::Spreadsheet.open(file_fixture("dummy.xlsx").to_s) }
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_fees, file: xlsx, sheet_name: xlsx.sheets.first) }

      it "returns successfully" do
        expect(result).not_to be_truthy
      end
    end
  end
end
