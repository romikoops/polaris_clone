# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Searchers::NestedCity do
  let(:result) { described_class.id(data: query) }

  describe ".data" do
    let!(:target_area) { FactoryBot.create(:swedish_location, osm_id: 1, admin_level: 7) }
    let(:target_point) { target_area.bounds.centroid }
    let!(:city_location) { FactoryBot.create(:xl_swedish_location, admin_level: 6) }
    let(:query) { { terms: ["Vastra Volunda", "Gothenburg"], country_code: "SE" } }

    context "with cities present" do
      before do
        Geocoder::Lookup::Test.add_stub("Vastra Volunda Gothenburg SE", [
          "address_components" => [{ "types" => ["premise"] }],
          "address" => "Vastra Volunda, Gothenburg, Sweden",
          "city" => "Gothenburg",
          "country" => "Sweden",
          "country_code" => "SE",
          "postal_code" => "21001",
          "geometry" => {
            "location" => {
              "lat" => target_point&.y,
              "lng" => target_point&.x
            }
          }
        ])
        FactoryBot.create(:locations_name,
          :reindex,
          location: target_area,
          point: target_point,
          city: "Gothenburg",
          name: "Vastra Volunda",
          country_code: "SE",
          place_rank: 70)
        FactoryBot.create(:locations_name,
          :reindex,
          location: city_location,
          point: city_location.bounds.centroid,
          city: "Gothenburg",
          name: "Gothenburg",
          country_code: "SE",
          place_rank: 50)
        Locations::Name.reindex
      end

      context "when the inner city is found" do
        it "finds the Name and returns the attached location" do
          expect(result).to eq(target_area.id)
        end
      end

      context "when falling back to contains" do
        let(:target_area) { nil }
        let(:target_point) { city_location.bounds.centroid }

        it "finds the Name and returns the attached location" do
          expect(result).to eq(city_location.id)
        end
      end
    end

    context "with no result" do
      let(:query) { { terms: ["Jonkoping"], country_code: "SE" } }

      before do
        Geocoder::Lookup::Test.add_stub("Jonkoping SE", [
          "address_components" => [{ "types" => ["premise"] }],
          "address" => "Jonkoping, Sweden",
          "city" => "Jonkoping",
          "country" => "Sweden",
          "country_code" => "SE",
          "postal_code" => "21001",
          "geometry" => {
            "location" => {
              "lat" => 31.2223,
              "lng" => 11.23224
            }
          }
        ])
      end

      it "returns nil when nothing is found" do
        expect(result).to eq(nil)
      end
    end
  end
end
