# frozen_string_literal: true

require 'rails_helper'

module Api
  RSpec.describe DashboardService, type: :service do
    let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary) }
    let(:trip) { FactoryBot.create(:legacy_trip, itinerary_id: itinerary.id) }
    let(:shipment) { FactoryBot.create(:legacy_shipment, itinerary_id: itinerary.id) }

    let(:quote_tenant) { FactoryBot.create(:legacy_tenant, name: 'Demo1', subdomain: 'demo1') }
    let(:booking_tenant) { FactoryBot.create(:legacy_tenant, name: 'Demo2', subdomain: 'demo2') }

    let(:quote_tenants_tenant) { Tenants::Tenant.find_by(legacy_id: quote_tenant.id) }
    let(:booking_tenants_tenant) { Tenants::Tenant.find_by(legacy_id: booking_tenant.id) }

    let!(:quote_tenants_scope) { FactoryBot.create(:tenants_scope, target: quote_tenants_tenant, content: { open_quotation_tool: true }) }
    let!(:booking_tenants_scope) { FactoryBot.create(:tenants_scope, target: booking_tenants_tenant, content: { open_quotation_tool: false }) }

    let(:quote_user_legacy) { FactoryBot.create(:legacy_user, tenant: quote_tenant, email: 't@example.com') }
    let(:booking_user_legacy) { FactoryBot.create(:legacy_user, tenant: booking_tenant, email: 't2@example.com') }
    let!(:quote_user) { Tenants::User.find_by(legacy_id: quote_user_legacy.id) }
    let!(:booking_user) { Tenants::User.find_by(legacy_id: booking_user_legacy.id) }
    let(:shanghai) { FactoryBot.create(:shanghai_hub) }
    let(:gothenburg) { FactoryBot.create(:gothenburg_hub) }
    let(:felixstowe) { FactoryBot.create(:felixstowe_hub) }

    describe 'returns Dashboard info for quote shop' do
      subject { described_class.new(user: quote_user) }

      let!(:shipments) do
        [
          FactoryBot.create(:complete_legacy_shipment,
                            user_id: quote_user.legacy_id,
                            tenant_id: quote_tenant.id,
                            status: 'quoted',
                            created_at: Time.zone.now - 1.day,
                            total_goods_value: 2000,
                            origin_nexus_id: shanghai.nexus_id,
                            origin_hub_id: shanghai.id,
                            destination_nexus_id: gothenburg.nexus_id,
                            destination_hub_id: gothenburg.id,
                            with_breakdown: true),

          FactoryBot.create(:complete_legacy_shipment,
                            user_id: quote_user.legacy_id,
                            tenant_id: quote_tenant.id,
                            status: 'booking_process_started',
                            created_at: Time.zone.now - 1.day,
                            total_goods_value: 1000,
                            origin_nexus_id: shanghai.nexus_id,
                            origin_hub_id: shanghai.id,
                            destination_nexus_id: felixstowe.nexus_id,
                            destination_hub_id: felixstowe.id,
                            with_breakdown: true),

          FactoryBot.create(:complete_legacy_shipment,
                            user_id: quote_user.legacy_id,
                            tenant_id: quote_tenant.id,
                            status: 'booking_process_started',
                            created_at: Time.zone.now - 1.day,
                            total_goods_value: 1000,
                            origin_nexus_id: shanghai.nexus_id,
                            origin_hub_id: shanghai.id,
                            destination_nexus_id: gothenburg.nexus_id,
                            destination_hub_id: gothenburg.id,
                            with_breakdown: true)
        ]
      end

      it 'returns a quotation shipment hash' do
        expect(subject.shipments_hash[:quoted].first).to eq(shipments.first)
        expect(subject.shipments_hash[:bookings_in_progress].count).to eq(2)
      end

      it 'returns a revenue array' do
        expect(subject.find_revenue[:rev_arr].count).to eq(3)
        expect(subject.find_revenue[:rev_total]).to eq(29.97)
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
      subject { described_class.new(user: booking_user) }

      let!(:booking_shipments) do
        [
          FactoryBot.create(:complete_legacy_shipment,
                            user_id: booking_user.legacy_id,
                            tenant_id: booking_tenant.id,
                            status: 'in_progress',
                            origin_nexus_id: shanghai.nexus_id,
                            origin_hub_id: shanghai.id,
                            destination_nexus_id: gothenburg.nexus_id,
                            destination_hub_id: gothenburg.id)
        ]
      end

      it 'returns a booking shipment hash' do
        expect(subject.shipments_hash[:open].first).to eq(booking_shipments.first)
      end
    end
  end
end
