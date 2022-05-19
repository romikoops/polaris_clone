# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Validators::LocationsLocation do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:base_row) do
    {
      "locations_location_id" => nil,
      "postal_code" => nil,
      "city" => nil,
      "locode" => nil,
      "distance" => nil,
      "zone" => 1.0,
      "identifier" => identifier,
      "query_type" => ExcelDataServices::V4::Extractors::QueryType::QUERY_TYPE_ENUM[query_type],
      "organization_id" => organization.id
    }
  end
  let(:extracted_table) { result.frame }
  let(:identifier) { "postal_code" }
  let(:query_type) { :postal_code }

  describe "#perform" do
    context "when string based zipcode with no location_id" do
      let(:location) { nil }
      let(:row) { base_row.merge({ identifier => "7795", "country_code" => "ZA" }) }

      it "returns no errors as the Query Type doesnt need a location id" do
        expect(result.errors).to be_empty
      end
    end

    context "when distance based with no location_id" do
      let(:identifier) { "distance" }
      let(:query_type) { :distance }
      let(:location) { nil }
      let(:row) { base_row.merge({ identifier => "75", "country_code" => "ZA" }) }

      it "returns no location id as the Query Type doesnt need one" do
        expect(result.errors).to be_empty
      end
    end

    context "when location based postal_code" do
      let(:query_type) { :location }
      let(:row) { base_row.merge({ identifier => "20457", "country_code" => "DE" }) }

      it "returns an error detailing what could not be found" do
        expect(result.errors.map(&:reason)).to include("The location '20457' cannot be found.")
      end
    end

    context "when locode based" do
      let(:query_type) { :location }
      let(:identifier) { "locode" }
      let(:row) { base_row.merge({ identifier => "DEHAM", "country_code" => "DE" }) }

      it "returns the frame with the location_id" do
        expect(result.errors.map(&:reason)).to include("The location 'DEHAM' cannot be found.")
      end
    end

    context "when city based" do
      let(:query_type) { :location }
      let(:identifier) { "city" }
      let(:row) { base_row.merge({ identifier => "Hamburg", "province" => "Hamburg", "country_code" => "DE" }) }

      before do
        Locations::Name.reindex
        Geocoder::Lookup::Test.add_stub("Hamburg Hamburg DE", [
          "address_components" => [{ "types" => ["premise"] }],
          "address" => "Hamburg Hamburg DE",
          "city" => "Hamburg",
          "country" => "Germany",
          "country_code" => "DE",
          "geometry" => {
            "location" => {
              "lat" => 11.2,
              "lng" => 38.4
            }
          }
        ])
      end

      it "returns the frame with the location_id" do
        expect(result.errors.map(&:reason)).to include("The location 'Hamburg' cannot be found.")
      end
    end
  end
end
