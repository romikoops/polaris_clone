# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::ActiveClientCount, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:admin_role) { FactoryBot.create(:legacy_role, name: 'admin') }
  let(:shipper_role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: admin_role, with_profile: true) }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let!(:clients) do
    %w[John Jane].map do |name|
      FactoryBot.create(:legacy_user,
                        tenant: legacy_tenant,
                        role: shipper_role,
                        with_profile: true,
                        first_name: name,
                        last_sign_in_at: Time.zone.now)
    end
  end
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) { described_class.data(user: user, start_date: start_date, end_date: end_date) }

  context 'with two active clients' do
    describe '.data' do
      it 'returns a the clients count for the time period' do
        expect(result).to eq(clients.length)
      end
    end
  end

  context 'with one non-active client' do
    before do
      FactoryBot.create(:legacy_user,
                        tenant: legacy_tenant,
                        role: shipper_role,
                        with_profile: true,
                        first_name: 'Ron',
                        last_sign_in_at: Time.zone.now - 2.months)
    end

    describe '.data' do
      it 'returns a the clients count for the time period' do
        expect(result).to eq(clients.length)
      end
    end
  end
end
