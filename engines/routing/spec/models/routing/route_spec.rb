require 'rails_helper'

module Routing
  RSpec.describe Route, type: :model do
    it 'creates a valid object' do
      route = FactoryBot.create(:routing_route)
      expect(route.valid?).to eq(true)
    end
  end
end
