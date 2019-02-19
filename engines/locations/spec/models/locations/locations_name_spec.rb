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

end

