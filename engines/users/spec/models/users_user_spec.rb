# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::User, type: :model do
  context 'validations' do
    it 'is valid with valid attributes' do
      expect(FactoryBot.build(:users_user)).to be_valid
    end

    it 'is unique' do
      user = FactoryBot.create(:users_user)

      expect(FactoryBot.build(:users_user, email: user.email)).not_to be_valid
    end
  end
end
