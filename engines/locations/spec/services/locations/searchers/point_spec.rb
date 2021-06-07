# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Searchers::Point do
  describe "data" do
    let(:result) { described_class.id(data: row) }
    let(:row) { { city: "Vastra Volunda", province: "Gothenburg", country_code: "SE" } }

    before do
      Geocoder::Lookup::Test.add_stub("Vastra Volunda Gothenburg SE", [
        "address_components" => [{ "types" => ["premise"] }],
        "address" => "Vastra Volunda Gothenburg, Sweden",
        "city" => "Vastra Volunda Gothenburg",
        "country" => "Sweden",
        "country_code" => "SE",
        "postal_code" => "21001",
        "geometry" => {
          "location" => {
            "lat" => point.y,
            "lng" => point.x
          }
        }
      ])
    end

    context "when admin level 3-8 available" do
      let!(:location) { FactoryBot.create(:swedish_location, osm_id: 4, admin_level: 7) }
      let(:point) { location.bounds.centroid }

      before { FactoryBot.create(:xl_swedish_location, admin_level: 8, osm_id: 41) }

      it "finds the correct location for the point" do
        expect(result).to eq(location.id)
      end
    end

    context "when admin level 3-8 not available" do
      let!(:location) { FactoryBot.create(:swedish_location, osm_id: 56, admin_level: 7) }
      let(:point) { location.bounds.centroid }

      before { FactoryBot.create(:xl_swedish_location, admin_level: 46, osm_id: 41) }

      it "finds the correct location for the point" do
        expect(result).to eq(location.id)
      end
    end
  end
end
