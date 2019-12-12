# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsSync::Routes do
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
  let!(:carrier) { FactoryBot.create(:routing_carrier) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let!(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant, mode_of_transport: 'air')}
  let!(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: tenant, mode_of_transport: 'truck')}
  let!(:itinerary_3) { FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: tenant, mode_of_transport: 'rail')}
  let!(:itinerary_4) { FactoryBot.create(:shanghai_felixstowe_itinerary, tenant: tenant)}
  let!(:itinerary_5) { FactoryBot.create(:hamburg_shanghai_itinerary, tenant: tenant)}
  let!(:itinerary_6) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: tenant)}

  let!(:routes) do
    FactoryBot.create(:freight_route, origin_location: :gothenburg, destination_location: :shanghai)
    FactoryBot.create(:freight_route, origin_location: :shanghai, destination_location: :gothenburg)
    FactoryBot.create(:freight_route, origin_location: :felixstowe, destination_location: :shanghai)
    FactoryBot.create(:freight_route, origin_location: :shanghai, destination_location: :felixstowe)
    FactoryBot.create(:freight_route, origin_location: :hamburg, destination_location: :shanghai)
    FactoryBot.create(:freight_route, origin_location: :shanghai, destination_location: :hamburg)
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
      described_class.new(tenant_id: tenants_tenant.id, sheet_type: :routes).perform
      expect(RmsData::Book.where(sheet_type: :routes).length).to eq(1)
      book = RmsData::Book.where(sheet_type: :routes).first
      expect(RmsData::Sheet.where(book_id: book.id).length).to eq(1)
      sheet = RmsData::Sheet.where(book_id: book.id).first
      expect(RmsData::Cell.where(sheet_id: sheet.id).length).to eq(143)
    end

  end
end
