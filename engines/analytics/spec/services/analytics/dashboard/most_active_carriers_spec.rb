# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Analytics::Dashboard::MostActiveCarriers, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:admin_role) { FactoryBot.create(:legacy_role, name: 'admin') }
  let(:shipper_role) { FactoryBot.create(:legacy_role, name: 'shipper') }
  let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: admin_role, with_profile: true) }
  let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
  let(:carrier_a) { FactoryBot.create(:legacy_carrier, name: 'A', code: 'a') }
  let(:carrier_b) { FactoryBot.create(:legacy_carrier, name: 'B', code: 'b') }
  let(:tenant_vehicle_a) { FactoryBot.create(:legacy_tenant_vehicle, name: 'TV- A', carrier: carrier_a, tenant: legacy_tenant) }
  let(:tenant_vehicle_b) { FactoryBot.create(:legacy_tenant_vehicle, name: 'TV-B', carrier: carrier_b, tenant: legacy_tenant) }
  let(:trip_a) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle_a) }
  let(:trip_b) { FactoryBot.create(:legacy_trip, tenant_vehicle: tenant_vehicle_b) }

  let(:clients) do
    %w[John Jane].map do |name|
      FactoryBot.create(:legacy_user, tenant: legacy_tenant, role: shipper_role, with_profile: true, first_name: name)
    end
  end

  let(:start_date) { Time.zone.now - 1.month }
  let(:end_date) { Time.zone.now }

  let(:result) { described_class.data(user: user, start_date: start_date, end_date: end_date) }

  before do
    client = clients.first

    [FactoryBot.create(:legacy_shipment,
                       trip: trip_a,
                       user: client,
                       tenant: legacy_tenant,
                       created_at: Time.zone.now - 2.months,
                       with_breakdown: true,
                       with_tenders: true),
     FactoryBot.create(:legacy_shipment,
                       trip: trip_a,
                       user: clients.first,
                       tenant: legacy_tenant,
                       with_breakdown: true,
                       with_tenders: true),
     FactoryBot.create(:legacy_shipment,
                       trip: trip_a,
                       user: clients.first,
                       tenant: legacy_tenant,
                       with_breakdown: true,
                       with_tenders: true),
     FactoryBot.create(:legacy_shipment,
                       trip: trip_b,
                       user: clients.first,
                       tenant: legacy_tenant,
                       with_breakdown: true,
                       with_tenders: true)]
  end

  describe 'data' do
    it 'returns an array of most active carriers for the period' do
      expect(result).to eq([{ count: 2, label: 'A' }, { count: 1, label: 'B' }])
    end
  end
end
