require 'rails_helper'


RSpec.describe Locations::Name, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      expect(FactoryBot.build(:locations_name)).to be_valid
    end

    # it 'is unique' do
    #   location_name = FactoryBot.create(:locations_name)

    #   expect(FactoryBot.build(:locations_name, name: location_name.name)).not_to be_valid
    # end
  end

  context 'retrieving data' do 
    let(:example_string) { 'Baoshun, China' }
    let(:location_name) { FactoryBot.create(:locations_name, city: 'Baoshun', country: 'China')}
    it 'returns the names in order as a string' do
      expect(location_name.description).to eq(example_string)
    end
  end
end

