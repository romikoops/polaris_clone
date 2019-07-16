# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe User, type: :model do
    describe '.full_name' do
      it 'returns the first and last name of the user' do
        user = FactoryBot.build(:legacy_user)
        expect(user.full_name).to eq('John Smith')
      end
    end

    describe '.full_name_and_company' do
      it 'returns the first and last name of the user' do
        user = FactoryBot.build(:legacy_user)
        expect(user.full_name_and_company).to eq('John Smith, ItsMyCargo')
      end
    end
  end
end
