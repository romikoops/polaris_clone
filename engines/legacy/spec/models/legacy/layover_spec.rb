# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Layover, type: :model do
    describe 'it creates a valid object' do
      it 'is valid' do
        expect(FactoryBot.build(:legacy_layover)).to be_valid
      end
    end
  end
end
