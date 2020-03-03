# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe UserAddress, type: :model do
    let(:user) { FactoryBot.create(:legacy_user) }
    let(:primary_user_address) { FactoryBot.create(:legacy_user_address, primary: true, user: user) }

    describe 'validity' do
      it 'is a valid user address' do
        expect(primary_user_address).to be_valid
      end
    end
  end
end
