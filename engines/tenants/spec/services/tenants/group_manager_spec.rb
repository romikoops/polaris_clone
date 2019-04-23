# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenants::GroupManager do
  let!(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  # let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  # let!(:tenants_user) { Tenants::User.find_by(legacy_id: user.id) }
  # let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
  # let!(:membership_1) { FactoryBot.create(:tenants_membership, member: tenants_user, group: group_1) }

  describe '.perform' do
    it 'adds the user to the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      add_user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
      add_tenants_user = Tenants::User.find_by(legacy_id: add_user.id)
      described_class.new(group_id: group.id, actions: { add: [add_tenants_user] }).perform
      expect(group.members).to eq([add_tenants_user])
    end

    it 'adds the user (Legacy) to the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      add_user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
      add_tenants_user = Tenants::User.find_by(legacy_id: add_user.id)
      described_class.new(group_id: group.id, actions: { add: [add_user] }).perform
      expect(group.members).to eq([add_tenants_user])
    end

    it 'adds the company to the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      company = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
      described_class.new(group_id: group.id, actions: { add: [company] }).perform
      expect(group.members).to eq([company])
    end

    it 'adds the group to the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      group_to_add = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      described_class.new(group_id: group.id, actions: { add: [group_to_add] }).perform
      expect(group.members).to eq([group_to_add])
    end

    it 'removes the user from the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      add_user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
      add_tenants_user = Tenants::User.find_by(legacy_id: add_user.id)
      FactoryBot.create(:tenants_membership, member: add_tenants_user, group: group)
      described_class.new(group_id: group.id, actions: { remove: [add_tenants_user] }).perform
      expect(group.members).to eq([])
    end

    it 'removes the user (Legacy) from the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      add_user = FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base)
      add_tenants_user = Tenants::User.find_by(legacy_id: add_user.id)
      FactoryBot.create(:tenants_membership, member: add_tenants_user, group: group)
      described_class.new(group_id: group.id, actions: { remove: [add_user] }).perform
      expect(group.members).to eq([])
    end

    it 'removes the company from the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      company = FactoryBot.create(:tenants_company, tenant: tenants_tenant)
      FactoryBot.create(:tenants_membership, member: company, group: group)
      described_class.new(group_id: group.id, actions: { remove: [company] }).perform
      expect(group.members).to eq([])
    end

    it 'removes the group from the group' do
      group = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      group_to_add = FactoryBot.create(:tenants_group, tenant: tenants_tenant)
      FactoryBot.create(:tenants_membership, member: group_to_add, group: group)
      described_class.new(group_id: group.id, actions: { remove: [group_to_add] }).perform
      expect(group.members).to eq([])
    end
  end
end
