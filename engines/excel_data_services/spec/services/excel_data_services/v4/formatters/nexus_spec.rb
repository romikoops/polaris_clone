# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::Nexus do
  include_context "V4 setup"

  describe ".insertable_data" do
    let(:rows) do
      [{
        "name" => "Abu Dhabi",
        "locode" => "AEAUH",
        "latitude" => 24.806936,
        "longitude" => 54.644405,
        "country" => "United Arab Emirates",
        "row_nr" => 2,
        "country_id" => 1,
        "organization_id" => organization.id
      },
        {
          "name" => "Adelaide",
          "locode" => "AUADL",
          "latitude" => -34.9284989,
          "longitude" => 138.6007456,
          "country" => "Australia",
          "row_nr" => 3,
          "country_id" => 2,
          "organization_id" => organization.id
        }]
    end
    let(:service) { described_class.state(state: state_arguments) }

    it "returns the formatted data" do
      expect(service.insertable_data).to match_array(rows.map { |datum| datum.slice("name", "locode", "organization_id", "country_id", "latitude", "longitude") })
    end
  end
end
