# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::LocationSeeder do
  context 'searching for location names' do
    before(:each) do
      Locations::Name.reindex
    end
    describe '.seeding' do
      let!(:location_1) { FactoryBot.create(:swedish_location, osm_id: 1, admin_level: 7) }
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
                            place_rank: 80)
        ]
      end

     

      it 'finds the Name and returns the attached location' do
        result = Locations::LocationSeeder.seeding('Vastra Volunda', 'Gothenburg')
        expect(result).to eq(location_2)
      end
    end

    # describe 'find_location_for_point' do
    #   let!(:location_admin_1) { FactoryBot.create(:swedish_location, osm_id: 4, admin_level: 7) }
    #   let!(:location_non_admin_1) { FactoryBot.create(:swedish_location, osm_id: 56) }
    #   let!(:location_admin_2) { FactoryBot.create(:xl_swedish_location, admin_level: 8, osm_id: 41) }
    #   let!(:location_non_admin_2) { FactoryBot.create(:xl_swedish_location, osm_id: 46) }
    #   it 'finds the correct location for the point' do
    #     point = location_admin_1.bounds.centroid
    #     result = Locations::LocationSeeder.find_location_for_point(lat: point.x, lon: point.y)
    #     expect(result).to eq(location_admin_1)
    #   end
    #   it 'finds the the smallest containing point if no adminlevel 3-8 areas are available' do
    #     point = location_non_admin_1.bounds.centroid
    #     result = Locations::LocationSeeder.find_location_for_point(lat: point.x, lon: point.y)
    #     expect(result).to eq(location_non_admin_1)
    #   end
    # end

    describe '.seeding_with_postal_code' do
      let!(:location_3) { FactoryBot.create(:german_postal_location) }

      it 'finds the correct location for the postal code polygon' do
        FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', point: location_3.bounds.centroid, place_rank: 40)
        FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', place_rank: 40)
        # Locations::Name.reindex
        result = Locations::LocationSeeder.seeding_with_postal_code(postal_code: '10001', country_code: 'de', terms: 'Innere Altstadt')
        expect(result).to eq(location_3)
      end

      let!(:location_4) { FactoryBot.create(:swedish_postal_location) }

      it 'finds the correct location for the postal code multi polygon' do
        FactoryBot.create(:locations_name, :reindex, osm_id: 18, city: 'Gothenburg', name: 'Vastra Folunda', point: location_4.bounds.centroid, place_rank: 40)
        FactoryBot.create(:locations_name, :reindex, osm_id: 19, city: 'Gothenburg', name: 'Port 4', place_rank: 40)
        # Locations::Name.reindex
        result = Locations::LocationSeeder.seeding_with_postal_code(postal_code: '22222', country_code: 'se', terms: 'Vastra Folunda')
        expect(result).to eq(location_4)
      end
    end

    describe '.seeding_with_locode' do
      let!(:locode_location) { FactoryBot.create(:swedish_location, osm_id: 1234) }
      let!(:locode_false_location) { FactoryBot.create(:xl_swedish_location, osm_id: 1235) }

      it 'finds the correct location for the locode' do
        FactoryBot.create(:locations_name, :reindex, osm_id: 100, locode: 'DEDRS', point: locode_location.bounds.centroid, place_rank: 40)
        # Locations::Name.reindex
        result = Locations::LocationSeeder.seeding_with_locode(locode: 'DEDRS')
        expect(result).to eq(locode_location)
      end

    end

    describe '.find_in_city' do
      let!(:location_1) { FactoryBot.create(:german_postal_location, admin_level: 6) }

      it 'finds the correct within city bounds' do
        FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Innere Altstadt', point: location_1.bounds.centroid, place_rank: 40)
        FactoryBot.create(:locations_name, :reindex, osm_id: 16, city: 'Dresden', name: 'Altstadt', place_rank: 40)
        # Locations::Name.reindex

        result = Locations::LocationSeeder.find_in_city(point: location_1.bounds.centroid, terms: 'Innere Altstadt', country_code: 'de')
        expect(result).to eq(location_1)
      end
    end
  end
end
