# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe DashboardService, type: :service do
    let!(:quote_tenant) { ::Legacy::Tenant.create(name: 'Demo1', subdomain: 'demo1', scope: { open_quotation_tool: true }) }
    let!(:booking_tenant) { ::Legacy::Tenant.create(name: 'Demo1', subdomain: 'demo1', scope: { open_quotation_tool: false }) }

    let!(:tenants) do [
      FactoryBot.create(:tenants_tenant, legacy_id: quote_tenant.id),
      FactoryBot.create(:tenants_tenant, legacy_id: booking_tenant.id),
    ]
    end
    let!(:quote_user_legacy) { FactoryBot.create(:legacy_user) }
    let!(:booking_user_legacy) { FactoryBot.create(:legacy_user) }
    let!(:quote_user) { FactoryBot.create(:tenants_user, email: 't@example.com', tenant: tenants.first, legacy_id: quote_user_legacy.id) }
    let!(:booking_user) { FactoryBot.create(:tenants_user, email: 't2@example.com', tenant: tenants.last, legacy_id: booking_user_legacy.id) }

    describe 'returns Dashboard info for quote shop' do
      subject { DashboardService.new(user: quote_user) }
      let!(:shipments) do
        [
          ::Legacy::Shipment.create(user_id: quote_user.legacy_id,
                                    tenant_id: quote_tenant.id,
                                    status: 'quoted',
                                    created_at: Time.now - 1.day,
                                    total_goods_value: 2000,
                                    destination_nexus_id: 1,
                                    origin_nexus_id: 2),
          ::Legacy::Shipment.create(user_id: quote_user.legacy_id,
                                    tenant_id: quote_tenant.id,
                                    status: 'booking_process_started',
                                    created_at: Time.now - 1.day,
                                    total_goods_value: 1000,
                                    destination_nexus_id: 3,
                                    origin_nexus_id: 4),
          ::Legacy::Shipment.create(user_id: quote_user.legacy_id,
                                    tenant_id: quote_tenant.id,
                                    status: 'booking_process_started',
                                    created_at: Time.now - 1.day,
                                    total_goods_value: 1000,
                                    destination_nexus_id: 1,
                                    origin_nexus_id: 2)
        ]
      end

      it 'returns a quotation shipment hash' do
        expect(subject.shipments_hash[:quoted].first).to eq(shipments.first)
        expect(subject.shipments_hash[:bookings_in_progress].count).to eq(2)
      end

      it 'returns a revenue array' do
        expect(subject.find_revenue[:rev_arr].count).to eq(3)
        expect(subject.find_revenue[:rev_total]).to eq(4000)
      end

      it 'returns a component config' do
        expect(subject.component_configuration).not_to be_nil
      end

      it 'returns user tradelanes with count' do
        expect(subject.find_tradelanes.count).to eq(2)
        expect(subject.find_tradelanes.first[:count]).to eq(2)
      end

      it 'returns data properly' do
        expect(subject.data).not_to be_nil
      end
    end
    describe 'returns Dashboard info for booking shop' do
      subject { DashboardService.new(user: booking_user) }

      let!(:booking_shipments) do
        [
          ::Legacy::Shipment.create(user_id: booking_user.legacy_id,
                                    tenant_id: booking_tenant.id,
                                    status: 'in_progress')
        ]
      end

      it 'returns a booking shipment hash' do
        expect(subject.shipments_hash[:open].first).to eq(booking_shipments.first)
      end
    end
  end
end
