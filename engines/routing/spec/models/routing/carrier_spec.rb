require 'rails_helper'

module Routing
  RSpec.describe Carrier, type: :model do
    it 'creates a valid object' do
      carrier = FactoryBot.create(:routing_carrier)
      expect(carrier.name).to eq('MSC')
      expect(carrier.abbreviated_name).to eq('MSC')
    end
  end
end
