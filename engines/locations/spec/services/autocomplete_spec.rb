# frozen_string_literal: true

require "rails_helper"

module Locations
  RSpec.describe Autocomplete do
    let!(:location) { FactoryBot.create(:locations_location, :in_china, osm_id: 331) }
    let!(:example_bounds) { RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(location.bounds)) }
    let!(:location_names) do
      [
        FactoryBot.create(:locations_name,
          :reindex,
          osm_id: 331,
          name: "Baoshun",
          city: "Shanghai",
          country_code: "cn",
          language: "en"),
        FactoryBot.create(:locations_name,
          :reindex,
          osm_id: 332,
          city: "Taicang",
          name: "Jingang",
          country_code: "cn",
          language: "en"),
        FactoryBot.create(:locations_name,
          :reindex,
          osm_id: 333,
          city: "Huli",
          name: "Xiamen",
          country_code: "cn",
          language: "en"),
        FactoryBot.create(:locations_name,
          :reindex,
          osm_id: 334,
          city: "宝山城市工业园区",
          name: "宝山区",
          country_code: "cn",
          language: "zh",
          country: "中国")
      ]
    end
    let(:target_result_en) { location_names.first }
    let(:target_result_zh) { location_names.last }
    let(:english_string) { "Baoshun, China" }
    let(:chinese_string) { "宝山城市工业园区, 中国" }
    let(:term) { "Baoshun" }
    let(:country_codes) { ["cn"] }
    let(:results) { described_class.search(term: term, country_codes: country_codes, lang: "en") }

    before do
      Locations::Name.reindex
    end

    context "with country codes" do
      it "returns results including the desired object (en) with country codes", :aggregate_failures do
        expect(results.first.name).to eq("Baoshun")
        expect(results.first.city).to eq("Shanghai")
        expect(results.first.geojson).to eq(example_bounds)
        expect(results.first.lat_lng).to eq({latitude: 31.2699895, longitude: 121.9318879})
        expect(results.first.class).to eq(Locations::NameDecorator)
      end
    end

    context "without country_codes" do
      let(:country_codes) { [] }

      it "returns results including the desired object (en) without country codes", :aggregate_failures do
        expect(results.first.name).to eq("Baoshun")
        expect(results.first.city).to eq("Shanghai")
        expect(results.first.geojson).to eq(example_bounds)
        expect(results.first.lat_lng).to eq({latitude: 31.2699895, longitude: 121.9318879})
        expect(results.first.class).to eq(Locations::NameDecorator)
      end
    end
  end
end
