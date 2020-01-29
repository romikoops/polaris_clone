# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Group, type: :model do
    context 'instance methods' do
      let!(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
      let!(:currency) { FactoryBot.create(:legacy_currency) }
      let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
      let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
      let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
      let(:group_2) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
      let!(:membership_1) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1) }
      let!(:membership_2) { FactoryBot.create(:tenants_membership, member: group_2, group: group_1) }

      describe '.groups' do
        it 'returns the groups that the group is a member of' do
          expect(group_2.groups).to eq([group_1])
        end
      end

      describe '.member_count' do
        it 'returns the member count of the group' do
          result = group_1.member_count
          expect(result).to eq(2)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: tenants_groups
#
#  id         :uuid             not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#  tenant_id  :uuid
#
# Indexes
#
#  index_tenants_groups_on_sandbox_id  (sandbox_id)
#  index_tenants_groups_on_tenant_id   (tenant_id)
#
