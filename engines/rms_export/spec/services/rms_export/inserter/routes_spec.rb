# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ::RmsExport::Inserter::Routes do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:tenant_vehicles) do
    [
      FactoryBot.create(:legacy_tenant_vehicle, name: 'slowest', organization: organization),
      FactoryBot.create(:legacy_tenant_vehicle,
                        name: 'fastest',
                        organization: organization,
                        carrier: FactoryBot.build(:legacy_carrier, name: 'MSC'))
    ]
  end
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:itinerary_1) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization, mode_of_transport: 'air')}
  let!(:itinerary_2) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization, mode_of_transport: 'truck')}
  let!(:itinerary_3) { FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization, mode_of_transport: 'rail')}
  let!(:itinerary_4) { FactoryBot.create(:shanghai_felixstowe_itinerary, organization: organization)}
  let!(:itinerary_5) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization)}
  let!(:itinerary_6) { FactoryBot.create(:shanghai_hamburg_itinerary, organization: organization)}

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
        pricings << FactoryBot.create(:lcl_pricing, itinerary: itinerary_1, organization: organization, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_20_pricing, itinerary: itinerary_2, organization: organization, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_pricing, itinerary: itinerary_3, organization: organization, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary_4, organization: organization, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_pricing, itinerary: itinerary_5, organization: organization, tenant_vehicle: tv)
        pricings << FactoryBot.create(:fcl_40_hq_pricing, itinerary: itinerary_6, organization: organization, tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_1, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_2, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_3, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_4, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_5, load_type: 'cargo_item', tenant_vehicle: tv)
        FactoryBot.create(:legacy_trip, itinerary: itinerary_6, load_type: 'cargo_item', tenant_vehicle: tv)
      end
      RmsSync::Routes.new(organization_id: organization.id, sheet_type: :routes).perform
      data = RmsExport::Parser::Routes.new(organization_id: organization.id).perform
      RmsExport::Inserter::Routes.new(organization_id: organization.id, data: data).perform

      expect(TenantRouting::Connection.count).to eq(6)
      expect(Routing::LineService.count).to eq(2)
      expect(Routing::RouteLineService.count).to eq(12)
    end

  end
end
