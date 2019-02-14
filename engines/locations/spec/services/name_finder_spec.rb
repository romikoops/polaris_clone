# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::NameFinder do
  context 'searching for location names' do
    describe '.seeding' do
      let!(:location_1) { FactoryBot.create(:locations_location, osm_id: 1) }
      let!(:location_2) { FactoryBot.create(:locations_location, osm_id: 6, name: 'AB') }
      let!(:location_3) { FactoryBot.create(:locations_location, osm_id: 7, name: 'AB10') }
      let!(:location_4) { FactoryBot.create(:locations_location, osm_id: 2, bounds: "010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F50") }
      let!(:cn_location_names) do
        [
          FactoryBot.create(:locations_name,
            :reindex,
            location: location_1,
            osm_id: 1,
            city: 'Shanghai',
            name: 'Baoshun',
            alternative_names: '宝山城市工业园区', place_rank: 50),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 2,
            city: 'Taicung',
            name: 'Baoshun',
            place_rank:  80),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 3,
            city: 'Qingdao',
            name: 'Baoshun',
            place_rank: 60 ),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 4,
            county: 'Shanghai',
            name: 'Baoshun',
            place_rank: 60 )
          ]
      end
      let!(:uk_location_names) do
        [
          FactoryBot.create(:locations_name,
            :reindex,
            location: location_3,
            osm_id: 7,
            city: '',
            name: 'AB10',
            postal_code: 'AB10',
            place_rank: 80 ),
          FactoryBot.create(:locations_name,
            :reindex,
            location: location_2,
            osm_id: 6,
            city: '',
            name: 'AB',
            postal_code: 'AB',
            place_rank: 60)
        ]
      end
      let!(:de_location_names) do
        [
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 17,
            location: location_4,
            city: 'Altenberg',
            name: 'Bårenfels',
            place_rank: 80 ),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 120,
            city: 'Alterneberg',
            name: 'Barenheld',
            place_rank: 80 ),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 16,
            city: 'Dresden',
            name: 'Altstadt',
            postal_code: 'AB',
            place_rank: 60),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 16,
            city: 'Dresden',
            name: 'Innere Altstadt',
            postal_code: 'AB',
            place_rank: 40)
        ]
      end

      let(:cn_target_location_name) { cn_location_names.first }
      let(:uk_target_location_name) { uk_location_names.last }
      let(:de_target_location_name) { de_location_names.first }

      it 'finds the correct location name through autocomplete search' do
        result = Locations::NameFinder.seeding('Baoshun', 'Shanghai')
        expect(result).to eq(cn_target_location_name)
      end

      it 'finds the correct location name through autocomplete search' do
        result = Locations::NameFinder.seeding('AB')
        expect(result).to eq(uk_target_location_name)
      end

      ## Other character sets slow down the process too much for now

      it 'finds the correct location name through autocomplete search in Chinese' do
        result = Locations::NameFinder.seeding('宝山城市工业园区', 'Shanghai')
        expect(result).to eq(cn_target_location_name)
      end

      it 'finds the correct location name with umlauts' do
        result = Locations::NameFinder.seeding('ALTENBERG', 'BAERENFELS')
        expect(result).to eq(de_target_location_name)
      end

      it 'finds the correct location name with nested areas' do
        result = Locations::NameFinder.seeding('innere altstadt', 'dresden')
        expect(result).to eq(de_location_names.last)
      end
    end

    describe '.seeding_with_postal_code' do 
      let!(:location_1) { FactoryBot.create(:locations_location, osm_id: 1, name: '10001', country_code: 'de') }
      let!(:location_name_1) { FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', point: location_1.bounds.centroid, place_rank: 40)}
      let!(:location_name_2) { FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt',  place_rank: 40)}

      it 'finds the correct name for the postal code' do
        result = Locations::NameFinder.seeding_with_postal_code(postal_code: '10001', country_code: 'de', terms: 'Innere Altstadt')
        expect(result).to eq(location_name_1)
      end
    end

  end
end
