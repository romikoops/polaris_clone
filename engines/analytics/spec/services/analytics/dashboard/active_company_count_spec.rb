# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::ActiveCompanyCount, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:admin_role) { FactoryBot.create(:legacy_role, name: 'admin') }
  let(:shipper_role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: admin_role, with_profile: true) }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }
  let(:company) { FactoryBot.create(:tenants_company, tenant: tenant) }
  let(:result) { described_class.data(user: user, start_date: start_date, end_date: end_date) }

  before do
    t = FactoryBot.create(:legacy_user,
                          tenant: legacy_tenant,
                          role: shipper_role,
                          with_profile: true,
                          first_name: 'Shipper',
                          last_sign_in_at: 2.days.ago)
    Tenants::User.find_by(legacy_id: t.id).update(company: company)
  end

  context 'with one active company' do
    describe '.data' do
      it 'returns the active company count for the time period' do
        expect(result).to eq(1)
      end
    end
  end
end
