# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Tables::XmlColumn do
  include_context "V4 setup"

  let(:service) { described_class.new(xml_data: xml_data, header: header, key: key, identifier: identifier, options: options) }
  let(:key) { "ChargeCode" }
  let(:header) { "fee_code" }
  let(:options) { ExcelDataServices::V4::Files::Tables::Options.new }
  let(:xml_data) { ExcelDataServices::V4::Files::XmlData.new(xml: xml, path: path, schema: schema) }
  let(:schema) do
    {
      identifier: "ChargeHeaderID",
      header: %w[ChargeHeader],
      body: %w[ChargeDetails Charge]
    }
  end
  let(:identifier) { "26971335" }
  let(:path) { %w[OceanFreightCharge RateDetails] }
  let(:xml) { Hash.from_xml(File.read(file_fixture("xml/example_grdb.xml"))) }

  describe "#frame" do
    let(:result) { service.frame }

    context "when the frame does have the key" do
      let(:expected_result) do
        Rover::DataFrame.new([
          { "value" => "OFR", "row" => 1, "header" => "fee_code", "sheet_name" => identifier, "column" => "ChargeCode", "organization_id" => organization.id },
          { "value" => "HAZ", "row" => 2, "header" => "fee_code", "sheet_name" => identifier, "column" => "ChargeCode", "organization_id" => organization.id },
          { "value" => "IM20", "row" => 3, "header" => "fee_code", "sheet_name" => identifier, "column" => "ChargeCode", "organization_id" => organization.id }
        ])
      end

      it "returns the the data from the xml in DataFrame format" do
        expect(result).to eq(expected_result)
      end
    end

    context "when the frame doesn't have the key" do
      let(:options) { ExcelDataServices::V4::Files::Tables::Options.new(options: { fallback: "x" }) }
      let(:expected_result) do
        Rover::DataFrame.new([
          { "value" => "x", "row" => 1, "header" => "fee_code", "sheet_name" => identifier, "column" => "blue", "organization_id" => organization.id },
          { "value" => "x", "row" => 2, "header" => "fee_code", "sheet_name" => identifier, "column" => "blue", "organization_id" => organization.id },
          { "value" => "x", "row" => 3, "header" => "fee_code", "sheet_name" => identifier, "column" => "blue", "organization_id" => organization.id }
        ])
      end

      let(:key) { "blue" }

      it "returns the fallback value times the number of records in the frame" do
        expect(result).to eq(expected_result)
      end
    end
  end

  describe "#valid?" do
    context "when there are no errors" do
      let(:options) { ExcelDataServices::V4::Files::Tables::Options.new }

      it "is is valid" do
        expect(service).to be_valid
      end
    end

    context "when there are errors" do
      let(:options) { ExcelDataServices::V4::Files::Tables::Options.new(options: { unique: true }) }

      before do
        allow(xml_data).to receive(:data_for).with(key: key, identifier: identifier).and_return(%w[OFR OFR])
      end

      it "is invalid due to the Uniqueness errors" do
        expect(service).not_to be_valid
      end
    end
  end

  describe "#errors" do
    context "when there are uniqueness errors" do
      let(:options) { ExcelDataServices::V4::Files::Tables::Options.new(options: { unique: true }) }

      before do
        allow(xml_data).to receive(:data_for).with(key: key, identifier: identifier).and_return(%w[OFR OFR])
      end

      it "returns the Uniqueness errors" do
        expect(service.errors.map(&:reason)).to include("Duplicates exist at (Sheet: #{identifier}) row: 1 column: ChargeCode & (Sheet: #{identifier}) row: 2 column: ChargeCode. Please remove all duplicate data and try again.")
      end
    end

    context "when there are required data errors" do
      let(:options) { ExcelDataServices::V4::Files::Tables::Options.new(options: { required: true }) }

      before do
        allow(xml_data).to receive(:data_for).with(key: key, identifier: identifier).and_return(["OFR", nil])
      end

      it "returns the Uniqueness errors" do
        expect(service.errors.map(&:reason)).to include("Required data is missing at: (Sheet: #{identifier}) row: 2 column: ChargeCode. Please fill in the missing data and try again.")
      end
    end
  end

  describe "#sheet_name" do
    it "returns the identifier" do
      expect(service.sheet_name).to eq(identifier)
    end
  end
end
