# frozen_string_literal: true

require 'rails_helper'

module Trucking
  RSpec.describe Location, type: :model do
    let(:location) { FactoryBot.create(:trucking_location) }
    it 'is valid with valid attributes' do
      expect(FactoryBot.build(:trucking_location)).to be_valid
    end
  end
end
