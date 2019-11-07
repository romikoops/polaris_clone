# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe User, type: :model do
    context 'legacy_sync' do
      let(:legacy_user) { FactoryBot.build(:legacy_user) }
      it 'creates from legacy' do
        user = described_class.create_from_legacy(legacy_user)
        expect(user).to be_valid
      end
    end

    context 'instance methods' do
      let!(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let!(:currency) { FactoryBot.create(:legacy_currency) }
      let(:address) { FactoryBot.create(:legacy_address) }
      let(:company) { FactoryBot.create(:tenants_company, tenant: tenants_tenant, address: address) }
      let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base, company_name: 'ItsMyCargo') }
      let!(:tenants_user) do
        Tenants::User.find_by(legacy_id: user.id).tap do |u|
          u.company = company
        end
      end
      let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
      let!(:membership_1) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1) }

      describe '.groups' do
        it 'returns the groups that the user is a member of' do
          expect(tenants_user.groups).to eq([group_1])
        end
      end

      describe '.all_groups' do
        let(:group_2) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
        let!(:membership_2) { FactoryBot.create(:tenants_membership, member: company, group: group_2) }
        it 'returns the groups that the user and company is a member of' do
          expect(tenants_user.all_groups).to match_array([group_1, group_2])
        end
      end

      describe '.verify_company' do
        it 'creates the company if it doesnt exist' do
          tenants_user.verify_company
          expect(tenants_user.company&.name).to eq('ItsMyCargo GmbH')
        end
      end
    end
  end
end
