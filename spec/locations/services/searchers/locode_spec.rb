# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Searchers::Locode do
  let(:result) { described_class.id(data: query) }

  describe ".data" do
    let!(:target_location) { FactoryBot.create(:german_location, name: "DEHAM", country_code: "de") }
    let(:query) { {locode: "DEHAM", country_code: "DE"} }

    it "finds the Name and returns the attached location" do
      expect(result).to eq(target_location.id)
    end

    context "with no result" do
      let(:query) { {locode: "ZACPT", country_code: "ZA"} }

      before do
        Geocoder::Lookup::Test.add_stub("ZACPT", [
          "address_components" => [{"types" => ["premise"]}],
          "address" => "Cape Town, South Africa",
          "city" => "Cape Town",
          "country" => "South Africa",
          "country_code" => "ZA",
          "postal_code" => "7995",
          "geometry" => {
            "location" => {
              "lat" => -34.2223,
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
