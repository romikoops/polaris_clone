# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsExport::Inserter::Routes do
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let!(:tenants_tenant) { FactoryBot.create(:tenants_tenant, legacy: tenant) }
  let(:tenant_vehicles) do
    [
      FactoryBot.create(:legacy_tenant_vehicle, name: 'slowest', tenant: tenant),
      FactoryBot.create(:legacy_tenant_vehicle,
                        name: 'fastest',
                        tenant: tenant,
                        carrier: FactoryBot.build(:legacy_carrier, name: 'MSC'))
    ]
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant, mode_of_transport: 'air')}
  let!(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: tenant, mode_of_transport: 'truck')}
  let!(:itinerary_3) { FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: tenant, mode_of_transport: 'rail')}
  let!(:itinerary_4) { FactoryBot.create(:shanghai_felixstowe_itinerary, tenant: tenant)}
  let!(:itinerary_5) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant)}
  let!(:itinerary_6) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: tenant)}

  let!(:locations) do
    [
      FactoryBot.create(:felixstowe_location),
      FactoryBot.create(:shanghai_location),
      FactoryBot.create(:gothenburg_location),
      FactoryBot.create(:rotterdam_location),
      FactoryBot.create(:ningbo_location),
      FactoryBot.create(:veracruz_location),
      FactoryBot.create(:hamburg_location)
    ]
  end
  describe '.perform' do
    it 'creates the routes' do
      pricings = []
      tenant_vehicles.each do |tv|
        pricings << FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_20_pricing, itinerary: itinerary_2, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_pricing, itinerary: itinerary_3, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary_4, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_pricing, itinerary: itinerary_5, tenant: tenant, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary_6, tenant: tenant, tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_1, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_2, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_3, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_4, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_5, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_6, load_type: 'cargo_item', tenant_vehicle: tv)
      end
      RmsSync::Routes.new(tenant_id: tenants_tenant.id, sheet_type: :routes).perform
      data = RmsExport::Parser::Routes.new(tenant_id: tenants_tenant.id).perform
      RmsExport::Inserter::Routes.new(tenant_id: tenants_tenant.id, data: data).perform

      expect(TenantRouting::Connection.count).to eq(6)
      expect(Routing::LineService.count).to eq(2)
      expect(Routing::RouteLineService.count).to eq(12)
    end

  end
end