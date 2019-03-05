# frozen_string_literal: true

require 'rails_helper'

module Locations
  RSpec.describe NameDecorator do
    let!(:location) { FactoryBot.create(:locations_location, osm_id: 123) }
    let!(:example_bounds) { RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(location.bounds)) }
    let!(:location_names) do
      [
        FactoryBot.create(:locations_name,
                          name: '',
                          city: 'Baoshun',
                          county: 'Shanghai',
                          osm_id: 123,
                          postal_code: 220_011,
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          :reindex,
                          name: '',
                          city: '宝山城市工业园区',
                          county: '宝山区',
                          osm_id: 123,
                          postal_code: 220_011,
                          language: 'zh', country: '中国')
      ]
    end
    let(:english_string) { 'Baoshun, 220011, Shanghai China' }
    let(:chinese_string) { '宝山城市工业园区, 220011, Shanghai 中国' }

    context 'base methods' do
      it 'returns a geoJson object' do
        expect(NameDecorator.new(location_names.first).geojson).to eq(example_bounds)
      end
      it 'returns the lat lon coordinates' do
        expect(NameDecorator.new(location_names.first).lat_lng).to eq(latitude: 31.2699895, longitude: 121.9318879)
      end
    end
  end
end
