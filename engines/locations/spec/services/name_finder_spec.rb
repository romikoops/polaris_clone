# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::NameFinder do
  context 'searching for location names' do
    describe '.seeding' do
      let!(:location_1) { FactoryBot.create(:chinese_location, osm_id: 1) }
      let!(:location_2) { FactoryBot.create(:chinese_location, osm_id: 6, name: 'AB') }
      let!(:location_3) { FactoryBot.create(:chinese_location, osm_id: 7, name: 'AB10') }
      let!(:location_4) { FactoryBot.create(:german_location, osm_id: 2) }
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
      before(:each) do 
        Locations::Name.search_index.delete
        Locations::Name.reindex
      end

      it 'finds the correct location name through autocomplete search' do
        cn_target_location_name = cn_location_names.first 
        result = Locations::NameFinder.seeding('Baoshun', 'Shanghai')
        expect(result).to eq(cn_target_location_name)
      end

      it 'finds the correct location name through autocomplete search' do
        uk_target_location_name = uk_location_names.last
        result = Locations::NameFinder.seeding('AB')
        expect(result).to eq(uk_target_location_name)
      end

      ## Other character sets slow down the process too much for now

      it 'finds the correct location name through autocomplete search in Chinese' do
        cn_target_location_name = cn_location_names.first 
        result = Locations::NameFinder.seeding('宝山城市工业园区', 'Shanghai')
        expect(result).to eq(cn_target_location_name)
      end

      it 'finds the correct location name with umlauts' do
        de_target_location_name = de_location_names.first
        result = Locations::NameFinder.seeding('ALTENBERG', 'BAERENFELS')
        expect(result).to eq(de_target_location_name)
      end

      it 'finds the correct location name with nested areas' do
        de_target_location_name = de_location_names.first
        result = Locations::NameFinder.seeding('innere altstadt', 'dresden')
        expect(result).to eq(de_location_names.last)
      end
    end

    describe '.seeding_with_postal_code' do 
      let!(:location_1) { FactoryBot.create(:german_postal_location) }

      it 'finds the correct name for the postal code' do
        location_name_1 = FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', point: location_1.bounds.centroid, place_rank: 40)
        location_name_2 = FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt',  place_rank: 40)
        result = Locations::NameFinder.find_in_postal_code(postal_bounds: location_1.bounds, terms: 'Innere Altstadt')
        expect(result).to eq(location_name_1)
      end
    end

  end
end
