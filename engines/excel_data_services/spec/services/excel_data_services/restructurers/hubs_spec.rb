# frozen_string_literal: false

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::Hubs do
  before do
    Geocoder::Lookup::Test.add_stub("Khalifa Port - Abu Dhabi - United Arab Emirates",
      [{ "coordinates" => [24.806936, 54.644405] }])
  end

  describe ".perform" do
    let(:data) do
      {
        sheet_name: "Hubs",
        restructurer_name: "hubs",
        rows_data: [
          {
            status: "active",
            type: "OCEAN",
            name: "Abu Dhabi",
            locode: "AEAUH",
            latitude: nil,
            longitude: nil,
            country: "United Arab Emirates",
            full_address: "Khalifa Port - Abu Dhabi - United Arab Emirates",
            photo: nil,
            free_out: "false",
            import_charges: "true",
            export_charges: "false",
            pre_carriage: nil,
            on_carriage: "false",
            alternative_names: nil,
            row_nr: 2
          },
          {
            status: "active",
            type: "ocean",
            name: "Adelaide",
            locode: "auadl",
            latitude: -34.9284989,
            longitude: 138.6007456,
            country: "Australia",
            full_address: "202 Victoria Square, Adelaide SA 5000, Australia",
            photo: nil,
            free_out: "false",
            import_charges: "true",
            export_charges: "false",
            pre_carriage: "false",
            on_carriage: "false",
            alternative_names: nil,
            row_nr: 3
          }
        ]
      }
    end
    let(:organization) { FactoryBot.create(:organizations_organization) }

    it "extracts the row data from the sheet hash" do
      result = described_class.restructure(organization: organization, data: data)
      expect(
        result["Hubs"].map { |hub| hub.dig(:nexus, :locode).upcase }
      ).to eq(result["Hubs"].map { |hub| hub.dig(:nexus, :locode) })
      expect(
        result["Hubs"].map { |hub| hub.dig(:hub, :hub_type).downcase }
      ).to eq(result["Hubs"].map { |hub| hub.dig(:hub, :hub_type) })
      expect(result["Hubs"].map { |hub| hub.dig(:address, :latitude) }).to match_array([24.806936, -34.9284989])
      expect(result["Hubs"].length).to be(2)
      expect(result.class).to be(Hash)
    end

    context "with missing lat lng values" do
      let(:data) { FactoryBot.build(:excel_data_parsed, :hubs_missing_lat_lon).first }
      let(:expected_result) do
        FactoryBot.build(:excel_data_restructured, :restructured_hubs_data, organization: organization)
      end

      it "extracts the row data from the sheet hash" do
        result = described_class.restructure(organization: organization, data: data)
        target = expected_result.find { |hub| hub.dig(:hub, :name) == data[:rows_data].first[:name] }
        expect(result["Hubs"].first[:address]).to eq(target[:address])
      end
    end

    context "with a missing address field" do
      before do
        Geocoder::Lookup::Test.add_stub("Sultan Lake, United Arab Emirates",
          [{ "coordinates" => [24.806936, 54.644405] }])
        Geocoder::Lookup::Test.add_stub([24.806936, 54.644405], [{
          address: "Khalifa Port - Abu Dhabi - United Arab Emirates",
          address_components: []
        }])
      end

      let(:data) { FactoryBot.build(:excel_data_parsed, :hubs_missing_address).first }
      let(:expected_result) do
        FactoryBot.build(:excel_data_restructured, :restructured_hubs_data, organization: organization)
      end

      it "extracts the row data from the sheet hash" do
        result = described_class.restructure(organization: organization, data: data)
        target = expected_result.find { |hub| hub.dig(:hub, :name) == data[:rows_data].first[:name] }
        expect(result["Hubs"].first[:address]).to eq(target[:address])
      end
    end

    context "with a boolean values" do
      let(:data) { FactoryBot.build(:excel_data_parsed, :hubs_with_boolean_values).first }
      let(:expected_result) do
        FactoryBot.build(:excel_data_restructured, :restructured_hubs_data, organization: organization)
      end

      it "extracts the row data from the sheet hash" do
        result = described_class.restructure(organization: organization, data: data)
        expect(result["Hubs"].length).to eq(1)
      end
    end
  end
end
