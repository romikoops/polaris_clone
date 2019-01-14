# frozen_string_literal: true

require 'rails_helper'

module Locations
  RSpec.describe Autocomplete do
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
                          locality_8: 'Taicang',
                          name: 'Jingang',
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          location: location,
                          locality_8: 'Huli',
                          name: 'Xiamen',
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          location: location,
                          locality_8: '宝山城市工业园区',
                          name: '宝山区',
                          language: 'zh', country: '中国')
      ]
    end
    let(:target_result) { locations_names.first }
    let(:english_string) { 'Baoshun, China' }
    let(:chinese_string) { '宝山城市工业园区, 中国' }

    context '.search' do
     
      it 'returns results including the desired object' do
        results = Autocomplete.search(term: 'Baoshun', countries: ['China'], lang: 'en')
        require 'pry';
        binding.pry
        expect(results).to include(target_result)
      end
      # it 'returns a geoJson object' do
      #   expect(LocationDecorator.new(location).geojson).to eq(example_bounds)
      # end
      # it 'returns a the description in the English' do
      #   expect(LocationDecorator.new(location).description('en')).to eq(english_string)
      # end
      # it 'returns a the description in the Chinese' do
      #   expect(LocationDecorator.new(location).description('zh')).to eq(chinese_string)
      # end
    end

  end
end
