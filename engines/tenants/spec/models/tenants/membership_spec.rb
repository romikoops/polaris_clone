# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Membership, type: :model do
    context 'instance methods' do
      let!(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let!(:currency) { FactoryBot.create(:legacy_currency) }

      describe '.member_name' do
        it 'returns the correct user name' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
          tenants_user = Tenants::User.find_by(legacy_id: user.id)
          FactoryBot.create(:profiles_profile, user_id: tenants_user.id, first_name: 'John', last_name: 'Smith')
          membership = Tenants::Membership.create(member: tenants_user, group: group)
          expect(membership.member_name).to eq('John Smith')
        end
        it 'returns the correct company name' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          company = FactoryBot.create(:tenants_company, name: 'ItsMyCargo', tenant: tenants_tenant)
          membership = Tenants::Membership.create(member: company, group: group)
          expect(membership.member_name).to eq('ItsMyCargo')
        end
      end

      describe '.member_email' do
        it 'returns the correct user email' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
          tenants_user = Tenants::User.find_by(legacy_id: user.id)
          membership = Tenants::Membership.create(member: tenants_user, group: group)
          expect(membership.member_email).to eq(user.email)
        end
        it 'returns the correct company email' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          company = FactoryBot.create(:tenants_company, name: 'ItsMyCargo', tenant: tenants_tenant)
          membership = Tenants::Membership.create(member: company, group: group)
          expect(membership.member_email).to eq(company.email)
        end
      end

      describe '.original_member_id' do
        it 'returns the correct user id' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
          tenants_user = Tenants::User.find_by(legacy_id: user.id)
          membership = Tenants::Membership.create(member: tenants_user, group: group)
          expect(membership.original_member_id).to eq(user.id)
        end
        it 'returns the correct company id' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          company = FactoryBot.create(:tenants_company, name: 'ItsMyCargo', tenant: tenants_tenant)
          membership = Tenants::Membership.create(member: company, group: group)
          expect(membership.original_member_id).to eq(company.id)
        end
      end

      describe '.human_type' do
        it 'returns the correct user type' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
          tenants_user = Tenants::User.find_by(legacy_id: user.id)
          membership = Tenants::Membership.create(member: tenants_user, group: group)
          expect(membership.human_type).to eq('client')
        end
        it 'returns the correct company type' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          company = FactoryBot.create(:tenants_company, name: 'ItsMyCargo', tenant: tenants_tenant)
          membership = Tenants::Membership.create(member: company, group: group)
          expect(membership.human_type).to eq('company')
        end
        it 'returns the correct company type' do
          group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
          group_2 = FactoryBot.create(:tenants_group, tenant: tenants_tenant, name: 'Sub Group')
          FactoryBot.create(:tenants_company, name: 'ItsMyCargo', tenant: tenants_tenant)
          membership = Tenants::Membership.create(member: group_2, group: group)
          expect(membership.human_type).to eq('group')
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: tenants_memberships
#
#  id          :uuid             not null, primary key
#  member_type :string
#  priority    :integer          default(0)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  group_id    :uuid
#  member_id   :uuid
#  sandbox_id  :uuid
#
# Indexes
#
#  index_tenants_memberships_on_member_type_and_member_id  (member_type,member_id)
#  index_tenants_memberships_on_sandbox_id                 (sandbox_id)
#
