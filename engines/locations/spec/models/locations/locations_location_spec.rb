# frozen_string_literal: true

require 'rails_helper'

module Locations
  RSpec.describe Location, type: :model do
    context 'validations' do
      let(:location) { FactoryBot.create(:locations_location) }
      it 'is valid with valid attributes' do
        expect(FactoryBot.build(:locations_name, location: location)).to be_valid
      end

      it 'is unique' do
        location_name = FactoryBot.create(:locations_name, location: location)

        expect(FactoryBot.build(:locations_name, name: location_name.name, location: location)).not_to be_valid
      end
    end

    context 'finding' do
      let!(:location) { FactoryBot.create(:locations_location) }
      let(:lat) { 31.310542 }
      let(:lon) { 121.3496233 }
      it 'finds the correct Location by lat lng pair' do
        results = Locations::Location.contains(lat: lat, lon: lon)
        expect(results).to include(location)
      end
    end
  end
end
