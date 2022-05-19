# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::Address do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:country) { FactoryBot.create(:legacy_country) }
  let(:address) { FactoryBot.build(:legacy_address, country: country) }

  describe ".state" do
    before do
      Geocoder::Lookup::Test.add_stub([address.latitude, address.longitude], [
        "address_components" => [{ "types" => ["premise"] }],
        "address" => address.geocoded_address,
        "city" => address.city,
        "country" => address.country.name,
        "country_code" => country.code,
        "postal_code" => address.zip_code
      ])
    end

    let(:row) do
      {
        "latitude" => address.latitude,
        "longitude" => address.longitude,
        "country_id" => country.id,
        "row" => 2,
        "organization_id" => organization.id
      }
    end

    it "returns the frame with the address_id" do
      expect(result.frame["address_id"].to_a).to be_present
    end
  end
end
