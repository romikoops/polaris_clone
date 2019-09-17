# frozen_string_literal: true

require 'rails_helper'

module TenantRouting
  RSpec.describe Visibility, type: :model do
    it 'creates a valid object' do
      connection = FactoryBot.build(:tenant_routing_visibility)
      expect(connection.valid?).to eq(true)
    end
  end
end
