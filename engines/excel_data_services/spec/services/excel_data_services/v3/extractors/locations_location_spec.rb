# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Extractors::LocationsLocation do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:base_row) do
    {
      "postal_code" => nil,
      "city" => nil,
      "locode" => nil,
      "distance" => nil,
      "zone" => 1.0,
      "identifier" => identifier,
      "query_type" => ExcelDataServices::V3::Extractors::QueryType::QUERY_TYPE_ENUM[query_type]
    }
  end
  let(:extracted_table) { result.frame }
  let(:identifier) { "postal_code" }
  let(:query_type) { :postal_code }
  let!(:location) do
    FactoryBot.create(:locations_location, name: row[identifier], country_code: row["country_code"].downcase)
  end

  describe "#perform" do
    context "when string based zipcode" do
      let(:location) { nil }
      let(:row) { base_row.merge({ identifier => "7795", "country_code" => "ZA" }) }

      it "returns no location id as the Query Type doesnt need one" do
        expect(extracted_table["locations_location_id"].to_a).to match_array([nil])
      end
    end

    context "when distance based" do
      let(:identifier) { "distance" }
      let(:query_type) { :distance }
      let(:location) { nil }
      let(:row) { base_row.merge({ identifier => "75", "country_code" => "ZA" }) }

      it "returns no location id as the Query Type doesnt need one" do
        expect(extracted_table["locations_location_id"].to_a).to match_array([nil])
      end
    end

    context "when location based postal_code" do
      let(:query_type) { :location }
      let(:row) { base_row.merge({ identifier => "20457", "country_code" => "DE" }) }

      it "returns the frame with the location_id" do
        expect(extracted_table["locations_location_id"].to_a).to include(location.id)
      end
    end

    context "when locode based" do
      let(:query_type) { :location }
      let(:identifier) { "locode" }
      let(:row) { base_row.merge({ identifier => "DEHAM", "country_code" => "DE" }) }

      it "returns the frame with the location_id" do
        expect(extracted_table["locations_location_id"].to_a).to include(location.id)
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
              "lat" => location.bounds.centroid.y,
              "lng" => location.bounds.centroid.x
            }
          }
        ])
      end

      it "returns the frame with the location_id" do
        expect(extracted_table["locations_location_id"].to_a).to include(location.id)
      end
    end
  end
end
