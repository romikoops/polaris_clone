# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V2::Formatters::Hub do
  include_context "for excel_data_services setup"

  describe ".insertable_data" do
    let(:rows) do
      [{
        "hub_status" => "active",
        "hub_type" => "ocean",
        "name" => "Abu Dhabi",
        "locode" => "AEAUH",
        "latitude" => 24.806936,
        "longitude" => 54.644405,
        "country" => "United Arab Emirates",
        "country_id" => 1,
        "address_id" => 1,
        "nexus_id" => 1,
        "mandatory_charge_id" => 1,
        "full_address" => "Khalifa Port - Abu Dhabi - United Arab Emirates",
        "terminal" => nil,
        "terminal_code" => nil,
        "photo" => nil,
        "free_out" => "false",
        "import_charges" => "true",
        "export_charges" => "false",
        "pre_carriage" => nil,
        "on_carriage" => "false",
        "alternative_names" => nil,
        "row_nr" => 2,
        "organization_id" => organization.id
      },
        {
          "hub_status" => "active",
          "hub_type" => "ocean",
          "name" => "Adelaide",
          "locode" => "AUADL",
          "latitude" => -34.9284989,
          "longitude" => 138.6007456,
          "country" => "Australia",
          "row_nr" => 3,
          "country_id" => 2,
          "address_id" => 2,
          "nexus_id" => 2,
          "mandatory_charge_id" => 2,
          "full_address" => "Sydney Port - Sydney - Australia",
          "terminal" => nil,
          "terminal_code" => nil,
          "photo" => nil,
          "free_out" => "false",
          "import_charges" => "true",
          "export_charges" => "false",
          "pre_carriage" => nil,
          "on_carriage" => "false",
          "alternative_names" => nil,
          "organization_id" => organization.id
        }]
    end

    let(:expected_data) do
      [{ "name" => "Abu Dhabi",
         "organization_id" => organization.id,
         "latitude" => 24.806936,
         "longitude" => 54.644405,
         "mandatory_charge_id" => 1,
         "hub_status" => "active",
         "hub_type" => "ocean",
         "terminal" => nil,
         "terminal_code" => nil,
         "nexus_id" => 1,
         "address_id" => 1,
         "hub_code" => "AEAUH",
         "point" => RGeo::Geos.factory(srid: 4326).point(54.644405, 24.806936) },
        { "name" => "Adelaide",
          "organization_id" => organization.id,
          "latitude" => -34.9284989,
          "longitude" => 138.6007456,
          "mandatory_charge_id" => 2,
          "hub_status" => "active",
          "hub_type" => "ocean",
          "terminal" => nil,
          "terminal_code" => nil,
          "nexus_id" => 2,
          "address_id" => 2,
          "hub_code" => "AUADL",
          "point" => RGeo::Geos.factory(srid: 4326).point(138.6007456, -34.9284989) }]
    end

    let(:service) { described_class.state(state: state_arguments) }

    it "returns the formatted data" do
      expect(service.insertable_data).to match_array(expected_data)
    end
  end
end
