# frozen_string_literal: true

require 'rails_helper'

module Shipments
  RSpec.describe LineItem, type: :model do
    it 'creates a valid line item' do
      line_item = FactoryBot.build(:shipments_line_item)
      expect(line_item).to be_valid
    end
  end
end
