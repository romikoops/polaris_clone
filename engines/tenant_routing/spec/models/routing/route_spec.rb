require 'rails_helper'

module TenantRouting
  RSpec.describe Route, type: :model do
    it 'creates a valid object' do
      connection = FactoryBot.create(:tenant_routing_route)
      expect(connection.valid?).to eq(true)
    end
  end
end
