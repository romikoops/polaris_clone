# frozen_string_literal: true

require 'rails_helper'

module Locations
  RSpec.describe LocationDecorator do
    let!(:location) { FactoryBot.create(:locations_location) }
    let!(:example_bounds) { RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(location.bounds)) }
    let!(:location_names) do
      [
        FactoryBot.create(:locations_name,
                          location: location,
                          locality_8: 'Baoshun',
                          name: 'Shanghai',
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          location: location,
                          locality_8: '宝山城市工业园区',
                          name: '宝山区',
                          language: 'zh', country: '中国')
      ]
    end
    let(:english_string) { 'Baoshun, China' }
    let(:chinese_string) { '宝山城市工业园区, 中国' }

    context 'base methods' do
      it 'returns a geoJson object' do
        expect(LocationDecorator.new(location).geojson).to eq(example_bounds)
      end
      it 'returns a the description in the English' do
        expect(LocationDecorator.new(location).description('en')).to eq(english_string)
      end
      it 'returns a the description in the Chinese' do
        expect(LocationDecorator.new(location).description('zh')).to eq(chinese_string)
      end
    end

    context 'autocomplete search' do
      it 'returns the object with geojson and english description' do
        result = LocationDecorator.new(location).search_result('en')
        expect(result[:description]).to eq(english_string)
        expect(result[:geojson]).to eq(example_bounds)
      end
      it 'returns the object with geojson and chinese description' do
        result = LocationDecorator.new(location).search_result('zh')
        expect(result[:description]).to eq(chinese_string)
        expect(result[:geojson]).to eq(example_bounds)
      end
    end
  end
end
