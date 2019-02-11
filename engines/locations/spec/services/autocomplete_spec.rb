# frozen_string_literal: true

require 'rails_helper'

module Locations
  RSpec.describe Autocomplete do
    let!(:location) { FactoryBot.create(:locations_location, osm_id: 331) }
    let!(:example_bounds) { RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(location.bounds)) }
    let!(:location_names) do
      [
        FactoryBot.create(:locations_name,
                          osm_id: 331,
                          city: 'Baoshun',
                          name: 'Shanghai',
                          country_code: 'cn',
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          osm_id: 332,
                          city: 'Taicang',
                          name: 'Jingang',
                          country_code: 'cn',
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          osm_id: 333,
                          city: 'Huli',
                          name: 'Xiamen',
                          country_code: 'cn',
                          language: 'en'),
        FactoryBot.create(:locations_name,
                          :reindex,
                          osm_id: 334,
                          city: '宝山城市工业园区',
                          name: '宝山区',
                          country_code: 'cn',
                          language: 'zh',
                          country: '中国')
      ]
    end
    let(:target_result_en) { location_names.first }
    let(:target_result_zh) { location_names.last }
    let(:english_string) { 'Baoshun, China' }
    let(:chinese_string) { '宝山城市工业园区, 中国' }

    context '.search' do
      it 'returns results including the desired object (en)' do
        results = Autocomplete.search(term: 'Baoshun', country_codes: ['cn'], lang: 'en')
        expect(results.first.city).to eq('Baoshun')
        expect(results.first.name).to eq('Shanghai')
        expect(results.first.geojson).to eq(example_bounds)
        expect(results.first.lat_lng).to eq({lat: 31.2699895, lng: 121.9318879})
        expect(results.first.class).to eq(Locations::NameDecorator)
      end
    end

  end
end
