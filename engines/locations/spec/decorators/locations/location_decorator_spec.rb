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
                          city: 'Baoshun',
                          name: 'Shanghai',
                          postal_code: 220011,
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          location: location,
                          city: '宝山城市工业园区',
                          name: '宝山区',
                          postal_code: 220011,
                          language: 'zh', country: '中国')
      ]
    end
    let(:english_string) { 'Baoshun, 220011, China' }
    let(:chinese_string) { '宝山城市工业园区, 220011, 中国' }

    context 'base methods' do
      it 'returns a geoJson object' do
        expect(LocationDecorator.new(location).geojson).to eq(example_bounds)
      end
      it 'returns the description in the English' do
        expect(LocationDecorator.new(location).description(lang: 'en')).to eq(english_string)
      end
      it 'returns the description in the Chinese' do
        expect(LocationDecorator.new(location).description(lang: 'zh')).to eq(chinese_string)
      end
      it 'returns the city in the English' do
        expect(LocationDecorator.new(location).city(lang: 'en')).to eq('Baoshun')
      end
      it 'returns the city in the Chinese' do
        expect(LocationDecorator.new(location).city(lang: 'zh')).to eq('宝山城市工业园区')
      end
      it 'returns the country in the English' do
        expect(LocationDecorator.new(location).country(lang: 'en')).to eq('China')
      end
      it 'returns the country in the Chinese' do
        expect(LocationDecorator.new(location).country(lang: 'zh')).to eq('中国')
      end
      it 'returns the postal_code' do
        expect(LocationDecorator.new(location).postal_code(lang: 'en')).to eq('220011')
      end
     
    end
  end
end
