# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::NameFinder do
  context 'searching for location names' do
    let!(:location) { FactoryBot.create(:locations_location) }
    let!(:location_2) { FactoryBot.create(:locations_location, bounds: "010300000001000000050000000831E1E1874F5E40B5B05D90E3493F400831E1E1874F5E40E9E390C3167D3F40D4FDADAE545C5E40E9E390C3167D3F40D4FDADAE545C5E40B5B05D90E3493F400831E1E1874F5E40B5B05D90E3493F50") }
    let!(:location_names) do
      [
        FactoryBot.create(:locations_name, location: location, locality_4: 'Shanghai', locality_8: 'Baoshun', name: nil),
        FactoryBot.create(:locations_name, location: location, locality_4: 'Taicung', locality_6: 'Baoshun', name: nil ),
        FactoryBot.create(:locations_name, location: location, locality_4: 'Qingdao', locality_6: 'Baoshun', name: nil )
      ]
    end

    let(:target_location_name) { location_names.first }


    it 'finds the correct location name through autocomplete search' do
      result = Locations::NameFinder.find_highest_admin_level('Baoshun', 'Shanghai')
      expect(result).to eq(location)
    end

    it 'raises an error when multiple matches are found' do
      FactoryBot.create(:locations_name, location: location_2, locality_4: 'Shanghai', locality_8: 'Baoshun', locality_5: 'test', name: nil)
      expect do
        Locations::NameFinder.find_highest_admin_level('Baoshun')
      end.to raise_error(Locations::NameFinder::MultipleResultsFound)
    end
  end
end
