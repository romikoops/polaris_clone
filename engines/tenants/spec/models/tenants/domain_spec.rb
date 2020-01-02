# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Domain, type: :model do
    it 'is valid' do
      expect(FactoryBot.build(:tenants_domain)).to be_valid
    end
  end
end
