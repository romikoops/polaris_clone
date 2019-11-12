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

    describe '.company_name' do
      it 'returns the property of model' do
        user = FactoryBot.build(:legacy_user)
        expect(user.company_name).to eq('ItsMyCargo')
      end

      it 'returns the agency name if it is null' do
        agency = FactoryBot.build(:legacy_agency)
        user = FactoryBot.build(:legacy_user, company_name: nil, agency: agency)
        expect(user.company_name).to eq(agency.name)
      end

      it 'returns null if company_name and agency are null' do
        user = FactoryBot.build(:legacy_user, company_name: nil, agency: nil)
        expect(user.company_name).to eq(nil)
      end
    end
  end
end
