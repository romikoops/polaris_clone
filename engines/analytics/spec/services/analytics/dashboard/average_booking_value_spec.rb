# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::AverageBookingValue, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:admin_role) { FactoryBot.create(:legacy_role, name: 'admin') }
  let(:shipper_role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: admin_role, with_profile: true) }
  let(:legacy_client) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: shipper_role, with_profile: true) }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) { described_class.data(user: user, start_date: start_date, end_date: end_date) }

  before do
    FactoryBot.create_list(:legacy_shipment,
                           2,
                           user: legacy_client,
                           tenant: legacy_tenant,
                           with_breakdown: true,
                           with_tenders: true)
  end

  context 'when a quote shop' do
    before { FactoryBot.create(:tenants_scope, target: tenant, content: { closed_quotation_tool: true }) }

    describe 'data' do
      it 'returns an object with average booking values' do
        expect(result).to eq(symbol: 'EUR',
                             value: 0.999e1)
      end
    end
  end

  context 'when a booking shop' do
    before do
      Quotations::Tender.find_each do |tender|
        FactoryBot.create(:shipments_shipment_request,
                          user: tender.quotation.tenants_user,
                          tenant: tenant,
                          tender: tender,
                          created_at: tender.quotation.created_at)
      end
    end

    describe 'data' do
      it 'returns an object with average booking values' do
        expect(result).to eq(symbol: 'EUR',
                             value: 0.999e1)
      end
    end
  end
end
