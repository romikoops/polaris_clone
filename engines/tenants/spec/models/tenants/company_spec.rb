# frozen_string_literal: true

require 'rails_helper'

module Tenants
  RSpec.describe Company, type: :model do
    let!(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenants_tenant) { Tenants::Tenant.find_by(legacy_id: tenant.id) }
    let!(:currency) { FactoryBot.create(:legacy_currency) }
    let(:address) { FactoryBot.create(:legacy_address) }
    let(:company) { FactoryBot.create(:tenants_company, tenant: tenants_tenant, address: address) }
    let!(:tenants_user) { FactoryBot.create(:tenants_user, company: company) }
    let(:group_1) { FactoryBot.create(:tenants_group, tenant: tenants_tenant) }
    let!(:membership_1) { FactoryBot.create(:tenants_membership, member: company, group: group_1) }

    describe '.groups' do
      it 'returns the groups that the company is a member of' do
        expect(company.groups).to eq([group_1])
      end
    end

    describe '.employee_count' do
      it 'returns the employeecount' do
        result = company.employee_count
        expect(result).to eq(1)
      end
    end

    describe '.for_table_json' do
      it 'returns company ready for the table' do
        result = company.for_table_json
        expect(result['id']).to eq(company.id)
      end
    end
  end
end

# == Schema Information
#
# Table name: tenants_companies
#
#  id          :uuid             not null, primary key
#  deleted_at  :datetime
#  email       :string
#  name        :string
#  phone       :string
#  vat_number  :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  address_id  :integer
#  external_id :string
#  sandbox_id  :uuid
#  tenant_id   :uuid
#
# Indexes
#
#  index_tenants_companies_on_sandbox_id  (sandbox_id)
#  index_tenants_companies_on_tenant_id   (tenant_id)
#
