require 'rails_helper'

module Routing
  RSpec.describe TransitTime, type: :model do
    it 'creates a valid object' do
      rls = FactoryBot.create(:routing_transit_time)
      expect(rls.valid?).to eq(true)
    end
  end
end
