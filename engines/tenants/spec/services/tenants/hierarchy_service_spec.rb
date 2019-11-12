# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenants::HierarchyService do
  describe '#perform' do
    context 'user is nil' do
      let(:user) { nil }

      it 'returns an empty array' do
        expect(described_class.new(target: user).fetch).to eq([])
      end
    end

    context 'user is not nil' do
      let(:tenant) { FactoryBot.create(:tenants_tenant) }
      let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }

      it 'returns the correct hierarchy' do
        expect(described_class.new(target: user).fetch).to eq([tenant, user])
      end
    end

    context 'target is a group' do
      let(:tenant) { FactoryBot.create(:tenants_tenant) }
      let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
      let(:group) { FactoryBot.create(:tenants_group, tenant: tenant) }
      let(:membership) { FactoryBot.create(:tenants_membership, group: group, member: user) }

      it 'returns the correct hierarchy with one group' do
        expect(described_class.new(target: group).fetch).to eq([tenant, group])
      end
    end

    context 'target is a company' do
      let(:tenant) { FactoryBot.create(:tenants_tenant) }
      let(:company) { FactoryBot.create(:tenants_company, tenant: tenant) }
      let(:user) do 
        FactoryBot.create(:tenants_user, tenant: tenant).tap do |new_user|
          new_user.company = company
        end
      end
      it 'returns the correct hierarchy with one group' do
        expect(described_class.new(target: company).fetch).to eq([tenant, company])
      end
    end
  end
end
