# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::XmlData do
  include_context "V4 setup"

  let(:service) { described_class.new(xml: xml, path: path, schema: schema) }
  let(:schema) do
    {
      identifier: "ChargeHeaderID",
      header: %w[ChargeHeader],
      body: %w[ChargeDetails Charge]
    }
  end
  let(:path) { %w[OceanFreightCharge RateDetails] }
  let(:xml) { Hash.from_xml(File.read(file_fixture("xml/example_grdb.xml"))) }

  describe "#data_for" do
    let(:key_data) { service.data_for(key: key, identifier: "26971335") }
    let(:key) { "OriginRegion" }

    context "when key is from the header section" do
      it "returns the value of the header section for each record in the body that matches the identifier value" do
        expect(key_data).to eq(%w[EMEA EMEA EMEA])
      end
    end

    context "when key is from the body section" do
      let(:key) { "ChargeCode" }

      it "returns the value of the body section for each record in the body that matches the identifier value" do
        expect(key_data).to eq(%w[OFR HAZ IM20])
      end
    end
  end

  describe "#count_for" do
    it "returns the number of records in the body that match the identifier value" do
      expect(service.count_for(identifier: "26971335")).to eq(3)
    end
  end

  describe "#identifiers" do
    it "returns an array of the identifiers" do
      expect(service.identifiers).to eq(%w[26971335 26971336])
    end
  end
end
