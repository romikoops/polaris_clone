# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::LocationsLocation do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments, target_frame: "zones") }
  let(:base_row) do
    {
      "postal_code" => nil,
      "city" => nil,
      "locode" => nil,
      "distance" => nil,
      "zone" => 1.0,
      "row" => 2,
      "range" => range,
      "identifier" => identifier,
      "organization_id" => organization.id,
      "query_type" => ExcelDataServices::V4::Extractors::QueryType::QUERY_TYPE_ENUM[query_type]
    }
  end
  let(:extracted_table) { result.frame("zones") }
  let(:frames) { { "zones" => frame } }
  let(:identifier) { "postal_code" }
  let(:query_type) { :postal_code }
  let(:range) { nil }
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

    context "when postal_city based (one city, many postal codes)" do
      let(:query_type) { :location }
      let(:identifier) { "postal_city" }
      let(:rows) do
        [
          { "postal_code" => "20457", "city" => "Hamburg", "country_code" => "DE" },
          { "postal_code" => "20459", "city" => "Hamburg", "country_code" => "DE", "row" => 3 }
        ].map do |zone_row|
          base_row.merge(zone_row)
        end
      end
      let(:point) { RGeo::Geos.factory(srid: 4326).point(11.1, 57.0) }
      let!(:location) do
        FactoryBot.create(:locations_location,
          name: "20457",
          country_code: "de",
          bounds: FactoryBot.build(:legacy_bounds, lat: point.y, lng: point.x, delta: 0.3))
      end
      let!(:postal_location) do
        FactoryBot.create(:locations_location,
          name: "20459",
          country_code: "de",
          bounds: FactoryBot.build(:legacy_bounds, lat: point.y, lng: point.x, delta: 0.3))
      end

      before do
        FactoryBot.create(:locations_location,
          name: "Hamburg",
          country_code: "de",
          bounds: FactoryBot.build(:legacy_bounds, lat: point.y, lng: point.x, delta: 0.6))
        Locations::Name.reindex
        Geocoder::Lookup::Test.add_stub("20457 Hamburg DE", [
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

      it "returns the frame with the postal location_ids" do
        expect(extracted_table["locations_location_id"].to_a).to match_array([postal_location.id, location.id])
      end
    end

    context "when postal_city based (one postal code, many cities)" do
      let(:query_type) { :location }
      let(:identifier) { "postal_city" }
      let(:rows) do
        [
          { "postal_code" => "03238", "city" => "Dollenchen", "country_code" => "DE" },
          { "postal_code" => "03238", "city" => "Finsterwalde", "country_code" => "DE", "row" => 3 }
        ].map do |zone_row|
          base_row.merge(zone_row)
        end
      end
      let(:point) { RGeo::Geos.factory(srid: 4326).point(11.1, 57.0) }
      let(:point_b) { RGeo::Geos.factory(srid: 4326).point(11.3, 57.1) }
      let!(:location) do
        FactoryBot.create(:locations_location,
          name: "Dollenchen",
          country_code: "de",
          bounds: FactoryBot.build(:legacy_bounds, lat: point.y, lng: point.x, delta: 0.3))
      end
      let!(:city_location) do
        FactoryBot.create(:locations_location,
          name: "Finsterwalde",
          country_code: "de",
          bounds: FactoryBot.build(:legacy_bounds, lat: point_b.y, lng: point_b.x, delta: 0.3))
      end

      before do
        FactoryBot.create(:locations_location,
          name: "03238",
          country_code: "de",
          bounds: FactoryBot.build(:legacy_bounds, lat: point.y, lng: point.x, delta: 5))
        FactoryBot.create(:locations_name, :reindex, name: "Dollenchen", city: "Dollenchen", location_id: location.id, country_code: "DE", point: point)
        FactoryBot.create(:locations_name, :reindex, name: "Finsterwalde", city: "Finsterwalde", location_id: city_location.id, country_code: "DE", point: point_b)
        Locations::Name.reindex
        Geocoder::Lookup::Test.add_stub("Dollenchen DE", [
          "address_components" => [{ "types" => ["premise"] }],
          "address" => "Hamburg Hamburg DE",
          "city" => "Hamburg",
          "country" => "Germany",
          "country_code" => "DE",
          "geometry" => {
            "location" => {
              "lat" => point.y,
              "lng" => point.x
            }
          }
        ])
        Geocoder::Lookup::Test.add_stub("Finsterwalde DE", [
          "address_components" => [{ "types" => ["premise"] }],
          "address" => "Hamburg Hamburg DE",
          "city" => "Hamburg",
          "country" => "Germany",
          "country_code" => "DE",
          "geometry" => {
            "location" => {
              "lat" => point_b.y,
              "lng" => point_b.x
            }
          }
        ])
      end

      it "returns the frame with the city location_ids" do
        expect(extracted_table["locations_location_id"].to_a).to match_array([city_location.id, location.id])
      end
    end

    context "when postal_city based (existing trucking locations)" do
      let(:query_type) { :location }
      let(:identifier) { "postal_city" }
      let(:row) do
        base_row.merge({ "postal_code" => "20457", "city" => "Hamburg", "country_code" => "DE" })
      end
      let(:point) { RGeo::Geos.factory(srid: 4326).point(11.1, 57.0) }
      let(:country) { factory_country_from_code(code: "DE") }
      let!(:location) do
        FactoryBot.create(:trucking_location,
          :with_location,
          data: "Hamburg",
          country: country,
          query: "location",
          identifier: "postal_city")
      end

      it "returns the frame with the existing trucking location location_ids" do
        expect(extracted_table["locations_location_id"].to_a).to match_array([location.location_id])
      end
    end
  end
end
