require 'rails_helper'

module Routing
  RSpec.describe Carrier, type: :model do
    it 'creates a valid object' do
      carrier = FactoryBot.build(:routing_carrier)
      expect(carrier).to be_valid
    end
  end
end
