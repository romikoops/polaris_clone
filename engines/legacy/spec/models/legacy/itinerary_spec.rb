# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Itinerary, type: :model do
    describe '.parse_load_type' do
      it 'returns the cargo_item for lcl' do
        itinerary = FactoryBot.create(:legacy_itinerary)
        expect(itinerary.parse_load_type('lcl')).to eq('cargo_item')
      end
      
      it 'returns the container for fcl' do
        itinerary = FactoryBot.create(:legacy_itinerary)
        expect(itinerary.parse_load_type('fcl')).to eq('container')
      end
    end
  end
end
