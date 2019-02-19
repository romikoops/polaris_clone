# frozen_string_literal: true

require 'rails_helper'

module Locations
  RSpec.describe Location, type: :model do
    context 'validations' do
      let(:location) { FactoryBot.create(:locations_location) }
      it 'is valid with valid attributes' do
        expect(FactoryBot.build(:locations_location)).to be_valid
      end

      it 'is unique' do
        location_1 = FactoryBot.create(:locations_location)

        expect(FactoryBot.build(:locations_location, name: location_1.name)).not_to be_valid
      end
    end

    context 'finding' do
      let!(:location) { FactoryBot.create(:locations_location, :in_china) }
      let(:lat) { 31.310542 }
      let(:lon) { 121.3496233 }
      it 'finds the correct Location by lat lng pair' do
        results = Locations::Location.contains(lat: lat, lon: lon)
        expect(results).to include(location)
      end
    end
  end
end
