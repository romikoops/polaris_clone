# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Searchers::Default do
  let(:result) { described_class.id(data: query) }

  describe ".data" do
    let!(:target_location) { FactoryBot.create(:swedish_location, osm_id: 1, admin_level: 7) }
    let(:query) { {terms: ["Vastra Volunda", "Gothenburg"], country_code: "SE"} }

    before do
      Geocoder::Lookup::Test.add_stub("Vastra Volunda Gothenburg SE", [
        "address_components" => [{"types" => ["premise"]}],
        "address" => "Vastra Volunda, Sweden",
        "city" => "Vastra Volunda",
        "country" => "Sweden",
        "country_code" => "SE",
        "postal_code" => "21001",
        "geometry" => {
          "location" => {
            "lat" => target_location.bounds.centroid.y,
            "lng" => target_location.bounds.centroid.x
          }
        }
      ])
    end

    it "finds the Name and returns the attached location" do
      expect(result).to eq(target_location.id)
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
