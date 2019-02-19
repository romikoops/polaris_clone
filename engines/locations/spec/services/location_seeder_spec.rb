# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::LocationSeeder do
  context 'searching for location names' do
    describe '.seeding' do
      let!(:location_1) { FactoryBot.create(:swedish_location, osm_id: 1) }
      let!(:location_2) { FactoryBot.create(:xl_swedish_location, admin_level: 6) }
      let!(:location_names) do
        [
          FactoryBot.create(:locations_name,
            :reindex,
            location: location_2,
            point: location_2.bounds.centroid,
            city: 'Gothenburg',
            name: 'Vastra Volunda',
            place_rank: 50),
          FactoryBot.create(:locations_name,
            :reindex,
            osm_id: 2,
            point: location_1.bounds.centroid,
            city: 'Gothenburg',
            name: 'Port 4',
            place_rank:  80)
          ]
      end
      
      before(:each) do 
        Locations::Name.reindex
      end

      it 'finds the Name and returns the attached location' do
        result = Locations::LocationSeeder.seeding('Vastra Volunda', 'Gothenburg')
        expect(result).to eq(location_2)
      end

      it 'finds the Name and returns the smallest area conatining the point' do
        result = Locations::LocationSeeder.seeding('port 4', 'Gothenburg')
        expect(result).to eq(location_1)
      end
    end

    describe '.seeding_with_postal_code' do 
      let!(:location_1) { FactoryBot.create(:german_postal_location) }

      it 'finds the correct location for the postal code' do
        location_name_1 = FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', point: location_1.bounds.centroid, place_rank: 40)
        location_name_2 = FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt',  place_rank: 40)
        Locations::Name.reindex
        result = Locations::LocationSeeder.seeding_with_postal_code(postal_code: '10001', country_code: 'de', terms: 'Innere Altstadt')
        expect(result).to eq(location_1)
      end
    end

    describe '.find_in_city' do 
      let!(:location_1) { FactoryBot.create(:german_postal_location, admin_level: 6) }

      it 'finds the correct within city bounds' do
        location_name_1 = FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', point: location_1.bounds.centroid, place_rank: 40)
        location_name_2 = FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Altstadt',  place_rank: 40)
        Locations::Name.reindex
        result = Locations::LocationSeeder.find_in_city(point: location_1.bounds.centroid, terms: 'Innere Altstadt', country_code: 'de')
        expect(result).to eq(location_1)
      end
    end

  end
end
