require 'rails_helper'

module Routing
  RSpec.describe LineService, type: :model do
    it 'creates a valid object' do
      line_service = FactoryBot.create(:routing_line_service)
      expect(line_service.valid?).to eq(true)
    end
  end
end
