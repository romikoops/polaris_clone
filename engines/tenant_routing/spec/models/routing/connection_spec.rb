require 'rails_helper'

module TenantRouting
  RSpec.describe Connection, type: :model do
    it 'creates a valid object' do
      connection = FactoryBot.create(:tenant_routing_connection)
      expect(connection.valid?).to eq(true)
    end
  end
end
