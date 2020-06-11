# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Validators::InsertableChecks::Hubs do
  let(:tenant) { create(:tenant) }
  let(:options) { {tenant: tenant, data: input_data, sheet_name: "Sheet1"} }

  before do
    Geocoder::Lookup::Test.add_stub([24.806936, 54.644405], [{
      "coordinates" => [24.806936, 54.644405],
      "geocoded_address" => "Khalifa Port - Abu Dhabi - United Arab Emirates",
      "country" => "United Arab Emirates",
      "country_code" => "AE",
      "address_components" => []
    }])
  end

  context "with faulty data" do
    let(:input_data) do
      [
        {
          row_nr: 2,
          address: {
            status: "active",
            type: "ocean",
            name: "Abu Dhabi",
            locode: "AEABD",
            latitude: 24.806936,
            longitude: 54.644405,
            country: {name: "Jamaica"},
            full_address: "Khalifa Port - Abu Dhabi - United Arab Emirates",
            photo: nil,
            free_out: false,
            import_charges: true,
            export_charges: false,
            pre_carriage: false,
            on_carriage: false,
            alternative_names: nil,
            row_nr: 2
          }
        }
      ]
    end

    describe ".validate coordinates within the correct country" do
      before do
        create(:legacy_country, name: "Jamaica", code: "JM")
        create(:legacy_country, name: "United Arab Emirates", code: "AE")
      end

      let(:expected_error) {
        {
          exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
          reason:
           "The given coordinates do not match the assigned country: Given Jamaica, Geocoded: United Arab Emirates.",
          row_nr: 2,
          sheet_name: "Sheet1",
          type: :error
        }
      }

      it "catches the wrong country for given coordinates" do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to match_array([expected_error])
      end
    end

    describe ".validate country exists in DB" do
      it "recognises the country doesnt exist in the db" do
        validator = described_class.new(options)
        validator.perform
        expect(validator.results).to eq(
          [
            {exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks,
             reason: "There exists no country with name: Jamaica.",
             row_nr: 2,
             sheet_name: "Sheet1",
             type: :error}
          ]
        )
      end
    end
  end
end
