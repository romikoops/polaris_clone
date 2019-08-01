require 'rails_helper'

module Routing
  RSpec.describe Location, type: :model do
    it 'creates a valid object' do
      hamburg = FactoryBot.create(:routing_location)
      expect(hamburg.locode).to eq('DEHAM')
    end
  end
end
