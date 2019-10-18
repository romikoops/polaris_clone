require 'rails_helper'

module Tenants
  RSpec.describe Theme, type: :model do
    it 'creates a valid theme' do
      expect(FactoryBot.build(:tenants_theme)).to be_valid
    end
  end
end
