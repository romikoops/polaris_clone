require 'rails_helper'

module Routing
  RSpec.describe Terminal, type: :model do
    it 'creates a valid object' do
      hamburg = FactoryBot.build(:routing_terminal)
      expect(hamburg.terminal_code).to eq('DEHAMPS')
    end
  end
end
