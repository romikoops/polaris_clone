require 'rails_helper'


RSpec.describe Locations::Name, type: :model do
  context 'validations' do
    let(:location) { FactoryBot.create(:locations_location)}
    it 'is valid with valid attributes' do
      expect(FactoryBot.build(:locations_name, location: location)).to be_valid
    end

    it 'is unique' do
      location_name = FactoryBot.create(:locations_name, location: location)

      expect(FactoryBot.build(:locations_name, name: location_name.name, location: location)).not_to be_valid
    end
  end

  context 'searching for location names' do 
    let(:location) { FactoryBot.create(:locations_location)}
    let(:location_name) { FactoryBot.create(:locations_name, location: location, locality_8: 'Baoshun')}
    it 'finds the correct location name through autocomplete search' do 
      results = Locations::Name.autocomplete('Baoshun')
      expect(results).to include(location_name)
    end
  end

  context 'retrieving data' do 
    let(:example_string) { 'Baoshun, Jingang, China' }
    let(:location) { FactoryBot.create(:locations_location)}
    let(:location_name) { FactoryBot.create(:locations_name, location: location, locality_8: 'Baoshun', locality_6: 'Jingang')}
    it 'returns the names in order as a string' do
      expect(location_name.description).to eq(example_string)
    end
  end
end

