# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Schemas::Validator do
  include_context "with real trucking_sheet"
  let(:source) { FactoryBot.build(:schemas_sheets_trucking_rates, file: xlsx, sheet_name: "Sheet3") }

  describe ".valid?" do
    context "with a valid rates sheet" do
      it "returns successfully" do
        expect(described_class.valid?(source: source)).to eq(true)
      end
    end

    context "with a valid zones sheet" do
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_zones, file: xlsx, sheet_name: "Zones") }

      it "returns successfully" do
        expect(described_class.valid?(source: source)).to eq(true)
      end
    end

    context "with a valid fees sheet" do
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_fees, file: xlsx, sheet_name: "Fees") }

      it "returns successfully" do
        expect(described_class.valid?(source: source)).to eq(true)
      end
    end

    context "with an invalid sheet" do
      let(:xlsx) { Roo::Spreadsheet.open(file_fixture("dummy.xlsx").to_s) }
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_fees, file: xlsx, sheet_name: xlsx.sheets.first) }

      it "returns successfully" do
        expect(described_class.valid?(source: source)).to eq(false)
      end
    end

    context "with an empty sheet" do
      let(:temp_file) { Tempfile.new(["empty", ".xlsx"], "tmp") }
      let(:temp_xlsx) do
        WriteXLSX.new(temp_file, tempdir: Rails.root.join("tmp/empty").to_s)
      end
      let(:xlsx) { Roo::Excelx.new(temp_file) }
      let(:source) { FactoryBot.build(:schemas_sheets_trucking_fees, file: xlsx, sheet_name: xlsx.sheets.first) }

      before { temp_xlsx.close }

      after { temp_file.delete }

      it "returns successfully" do
        expect(described_class.valid?(source: source)).to eq(false)
      end
    end
  end
end
