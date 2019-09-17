require 'rails_helper'

module Routing
  RSpec.describe Location, type: :model do
    it 'creates a valid object' do
      hamburg = FactoryBot.build(:routing_location, locode: 'DEHAM')
      expect(hamburg.locode).to eq('DEHAM')
    end
  end
end
