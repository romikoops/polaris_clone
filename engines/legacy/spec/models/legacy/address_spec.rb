# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Address, type: :model do
    describe '.get_zip_code' do
      it 'returns the zipcode' do
        address = FactoryBot.create(:legacy_address, zip_code: '1234')
        expect(address.get_zip_code).to eq('1234')
      end
    end
  end
end
