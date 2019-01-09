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
end

