# frozen_string_literal: true

require "rails_helper"

RSpec.describe Locations::Finders::PostalCode do
  describe "data" do
    let(:result) { described_class.data(data: row) }
    let(:row) do
      {
        terms: ["Vastra Volunda, Gothenburg"],
        postal_bounds: postal_location.bounds,
        country_code: "SE"
      }
    end
    let(:postal_location) { FactoryBot.create(:swedish_location, osm_id: 4, admin_level: 10, name: "21001", country_code: "SE") }
    let(:point) { postal_location.bounds.centroid }
    let!(:target_location_name) do
      FactoryBot.create(:locations_name,
        name: 'Vastra Volanda,
        Gothenburg',
        postal_code: "21001",
        country_code: "SE",
        location: postal_location,
        point: point)
    end

    before do
      Geocoder::Lookup::Test.add_stub("Vastra Volunda Gothenburg SE",
        [
          "address_components" => [{"types" => ["premise"]}],
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

    context "when postal code is on the name" do
      before do
        FactoryBot.create(:xl_swedish_location, admin_level: 8, osm_id: 41)
        Locations::Name.reindex
      end

      it "finds the correct location for the point" do
        expect(result).to eq(target_location_name)
      end
    end

    context "when nothing is found available" do
      it "returns nil" do
        expect(result).to eq(nil)
      end
    end
  end
end
