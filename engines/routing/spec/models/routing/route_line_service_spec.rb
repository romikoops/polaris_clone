require 'rails_helper'

module Routing
  RSpec.describe RouteLineService, type: :model do
    it 'creates a valid object' do
      rls = FactoryBot.create(:routing_route_line_service)
      expect(rls.valid?).to eq(true)
    end
  end
end
