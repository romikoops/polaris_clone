# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Locations::NameFinder do
  context 'searching for location names' do
    let!(:location) { FactoryBot.create(:locations_location) }
    let!(:location_names) do
      [
        FactoryBot.create(:locations_name, location: location, locality_8: 'Baoshun', name: 'Shanghai'),
        FactoryBot.create(:locations_name, location: location, locality_6: 'Baoshun', name: 'Taicung'),
        FactoryBot.create(:locations_name, location: location, locality_6: 'Baoshun', name: 'Qingdao')
      ]
    end

    let(:target_location_name) { location_names.first }


    it 'finds the correct location name through autocomplete search' do
      result = Locations::NameFinder.find_highest_admin_level('Baoshun', 'Shanghai')
      expect(result).to eq(target_location_name)
    end

    it 'raises an error when multiple matches are found' do
      FactoryBot.create(:locations_name, location: location, locality_8: 'Baoshun', locality_5: 'test')
      expect do
        Locations::NameFinder.find_highest_admin_level('Baoshun')
      end.to raise_error(Locations::NameFinder::MultipleResultsFound)
    end
  end
end
