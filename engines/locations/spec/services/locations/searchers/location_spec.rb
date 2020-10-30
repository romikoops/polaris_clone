# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Searchers::City do
  let(:result) { described_class.id(data: query) }

  describe ".data" do
    let!(:location_1) { FactoryBot.create(:swedish_location, osm_id: 1, admin_level: 7) }
    let!(:location_2) { FactoryBot.create(:xl_swedish_location, admin_level: 6) }
    let(:query) { {terms: ["Vastra Volunda", "Gothenburg"], country_code: "SE"} }

    before do
      FactoryBot.create(:locations_name,
        :reindex,
        location: location_2,
        point: location_2.bounds.centroid,
        city: "Gothenburg",
        name: "Vastra Volunda",
        place_rank: 50)
      FactoryBot.create(:locations_name,
        :reindex,
        osm_id: 2,
        point: location_1.bounds.centroid,
        city: "Gothenburg",
        name: "Port 4",
        place_rank: 80)

      Locations::Name.reindex
    end

    it "finds the Name and returns the attached location" do
      expect(result).to eq(location_2.id)
    end

    context "with no result" do
      let(:query) { {terms: ["Jonkoping"], country_code: "SE"} }

      before do
        Geocoder::Lookup::Test.add_stub("Jonkoping SE", [
          "address_components" => [{"types" => ["premise"]}],
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
