# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe User, type: :model do
    let(:user) { FactoryBot.build(:legacy_user) }
    let(:agency) { FactoryBot.build(:legacy_agency) }
    let(:role) { FactoryBot.create(:legacy_role, name: 'agent') }
    let(:agency_user) { FactoryBot.build(:legacy_user, company_name: nil, agency: agency, role: role) }
    let(:user_no_company) { FactoryBot.build(:legacy_user, company_name: nil, agency: nil) }

    describe '.full_name' do
      it 'returns the first and last name of the user' do
        expect(user.full_name).to eq('John Smith')
      end
    end

    describe '.full_name_and_company' do
      it 'returns the first and last name of the user' do
        expect(user.full_name_and_company).to eq('John Smith, ItsMyCargo')
      end
    end

    describe '.company_name' do
      it 'returns the property of model' do
        expect(user.company_name).to eq('ItsMyCargo')
      end

      it 'returns the agency name if it is null' do
        expect(agency_user.company_name).to eq(agency.name)
      end

      it 'returns null if company_name and agency are null' do
        expect(user_no_company.company_name).to eq(nil)
      end
    end

    describe '#pricing_id' do
      it 'get the princing id from agency if it is has agency role' do
        expect(agency_user.pricing_id).to eq(agency_user.agency.agency_manager_id)
      end

      it 'get the user id if it is in the agency group' do
        expect(user.pricing_id).to eq(user.id)
      end
    end
  end
end
