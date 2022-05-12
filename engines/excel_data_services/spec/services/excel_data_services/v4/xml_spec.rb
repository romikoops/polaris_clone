# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Xml do
  let(:service) { described_class.new(document: file) }
  let(:xml) { File.open(file_fixture("xml/example_grdb.xml")) }
  let!(:file) do
    FactoryBot.create(:legacy_file).tap do |file_object|
      file_object.file.attach(io: xml, filename: "test.xml", content_type: "application/xhtml+xml")
    end
  end

  describe "#xml" do
    let(:result) { service.xml }

    it "returns the xml as a hash", :aggregate_failures do
      expect(result).to be_a(Hash)
      expect(result["OceanFreightCharge"]).to be_present
    end
  end
end
