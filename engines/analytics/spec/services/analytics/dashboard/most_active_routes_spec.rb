# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::MostActiveRoutes, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:admin_role) { FactoryBot.create(:legacy_role, name: 'admin') }
  let(:shipper_role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: admin_role, with_profile: true) }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:company) { FactoryBot.create(:tenants_company, name: 'Company Name') }
  let(:itineraries) do
    itin_syms = %i[gothenburg_shanghai_itinerary shanghai_gothenburg_itinerary]
    itin_syms.map do |sym|
      FactoryBot.create(sym, tenant: legacy_tenant)
    end
  end
  let(:clients) do
    %w[John Jane].map do |name|
      FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: shipper_role, with_profile: true, first_name: name)
    end
  end

  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) { described_class.data(user: user, start_date: start_date, end_date: end_date) }

  before do
    itineraries.map do |itinerary|
      FactoryBot.create(:legacy_shipment,
                        itinerary: itinerary,
                        tenant: legacy_tenant,
                        with_breakdown: true,
                        with_tenders: true)
    end
  end

  context 'when a quote shop' do
    before { FactoryBot.create(:tenants_scope, target: tenant, content: { closed_quotation_tool: true }) }

    describe '.data' do
      it 'returns an array with the itinerary count for the time period' do
        expect(result).to eq([{ count: 2, label: 'Gothenburg - Shanghai' }])
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

    describe '.data' do
      it 'returns an array with the itinerary count for the time period' do
        expect(result).to eq([{ count: 2, label: 'Gothenburg - Shanghai' }])
      end
    end
  end
end
