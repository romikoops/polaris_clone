require 'rails_helper'

module Trucking
  RSpec.describe Courier, type: :model do
    context 'validations' do
      let(:courier) { FactoryBot.create(:trucking_courier) }
      it 'is valid with valid attributes' do
        expect(FactoryBot.build(:trucking_courier)).to be_valid
      end
    end
  end
end
