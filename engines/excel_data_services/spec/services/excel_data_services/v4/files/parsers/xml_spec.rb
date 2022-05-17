# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Files::Parsers::Xml do
  include_context "V4 setup"

  let(:service) { described_class.new(section: section_string, state: state_arguments) }
  let(:xml) { File.open(file_fixture("xml/example_grdb.xml")) }
  let(:file) do
    FactoryBot.create(:legacy_file).tap do |file_object|
      file_object.file.attach(io: xml, filename: "test.xml", content_type: "application/xhtml+xml")
    end
  end
  let(:section_string) { "GrdbXml" }

  expected_headers = %w[charge_id
    request_type
    fee_code
    fee_name
    aspect
    currency
    rate
    rate_basis
    basis_name
    minimum
    maximum
    scale_uom
    range_min
    range_max
    notes
    effective_date
    expiration_date
    mandatory
    charge_header_id
    charge_details_type
    wwa_member
    customer
    origin_region
    origin_country_code
    origin_inland_cfs
    origin_consol_cfs
    origin_locode
    transshipment_1
    transshipment_2
    transshipment_3
    destination_locode
    destination_deconsol_cfs
    destination_cfs
    destination_country_code
    destination_region
    quoting_region
    carrier_code
    carrier
    service
    mode_of_transport
    group_id
    group_name
    cargo_class
    load_type]

  describe "#xml_columns" do
    it "returns all xml_columns defined in the schema", :aggregate_failures do
      expect(service.xml_columns.count).to eq(88)
      expect(service.xml_columns.map(&:header).uniq).to match_array(expected_headers)
    end
  end

  describe "#xml_data" do
    let(:result) { service.xml_data }

    it "returns the xml_context wrapped in a XmlData class" do
      expect(service.xml_data).to be_a(ExcelDataServices::V4::Files::XmlData)
    end
  end

  describe "#headers" do
    it "returns the headers of all XmlColumns defined in the schema" do
      expect(service.headers.uniq).to match_array(expected_headers)
    end
  end
end
