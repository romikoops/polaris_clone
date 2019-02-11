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
                          osm_id: -123,
                          postal_code: 220011,
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          :reindex,
                          name: '',
                          city: '宝山城市工业园区',
                          county: '宝山区',
                          osm_id: -123,
                          postal_code: 220011,
                          language: 'zh', country: '中国')
      ]
    end
    let(:english_string) { 'Baoshun, 220011, Shanghai China' }
    let(:chinese_string) { '宝山城市工业园区, 220011, Shanghai 中国' }

    context 'base methods' do
      it 'returns a geoJson object' do
        expect(NameDecorator.new(location_names.first).geojson).to eq(example_bounds)
      end
      # it 'returns the description in the English' do
      #   expect(NameDecorator.new(location).description(lang: 'en')).to eq(english_string)
      # end
      # it 'returns the description in the Chinese' do
      #   expect(NameDecorator.new(location).description(lang: 'zh')).to eq(chinese_string)
      # end
      # it 'returns the city in the English' do
      #   expect(NameDecorator.new(location).city(lang: 'en')).to eq('Baoshun')
      # end
      # it 'returns the city in the Chinese' do
      #   expect(NameDecorator.new(location).city(lang: 'zh')).to eq('宝山城市工业园区')
      # end
      # it 'returns the country in the English' do
      #   expect(NameDecorator.new(location).country(lang: 'en')).to eq('China')
      # end
      # it 'returns the country in the Chinese' do
      #   expect(NameDecorator.new(location).country(lang: 'zh')).to eq('中国')
      # end
      # it 'returns the postal_code' do
      #   expect(NameDecorator.new(location).postal_code(lang: 'en')).to eq('220011')
      # end
     
    end
  end
end
