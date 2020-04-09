# frozen_string_literal: true

require 'rails_helper'

module Wheelhouse
  RSpec.describe EquipmentService, type: :service do
    let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
    let(:tenant) { Tenants::Tenant.find_by(legacy: legacy_tenant) }
    let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
    let(:itinerary) { FactoryBot.create(:shanghai_gothenburg_itinerary, tenant: legacy_tenant) }
    let(:fcl_40_hq_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, tenant: legacy_tenant) }
    let(:gothenburg) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
    let(:shanghai) { itinerary.hubs.find_by(name: 'Shanghai Port') }
    let(:hamburg) { fcl_40_hq_itinerary.hubs.find_by(name: 'Hamburg Port') }
    let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, tenant: legacy_tenant) }

    before do
      FactoryBot.create(:fcl_20_pricing, tenant: legacy_tenant, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:fcl_40_pricing, tenant: legacy_tenant, itinerary: itinerary, tenant_vehicle: tenant_vehicle)
      FactoryBot.create(:fcl_40_hq_pricing, tenant: legacy_tenant, itinerary: fcl_40_hq_itinerary, tenant_vehicle: tenant_vehicle)
    end

    describe '.perform' do
      context 'with no nexus ids' do
        it 'returns all the cargo classes for all itineraries' do
          results = described_class.new(user: user).perform
          expect(results).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
        end
      end

      context 'with origin nexus id' do
        it 'returns all the cargo classes for all itineraries for origin' do
          results = described_class.new(user: user, origin: { nexus_id: shanghai.nexus_id }).perform
          expect(results).to match_array(%w[fcl_20 fcl_40 fcl_40_hq])
        end
      end

      context 'with destination nexus id' do
        it 'returns all the cargo classes for all itineraries for destination' do
          results = described_class.new(user: user, destination: { nexus_id: gothenburg.nexus_id }).perform
          expect(results).to match_array(%w[fcl_20 fcl_40])
        end
      end

      context 'with origin and destination nexus id' do
        it 'returns all the cargo classes for all itineraries for origin and destination' do
          results = described_class.new(user: user, origin: { nexus_id: shanghai.nexus_id }, destination: { nexus_id: hamburg.nexus_id }).perform
          expect(results).to match_array(%w[fcl_40_hq])
        end
      end

      context 'with origin and destination lat lngs' do
        before do
          FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: shanghai, cargo_class: 'fcl_40_hq', load_type: 'container', location: origin_trucking_location, truck_type: 'chassis')
          FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: hamburg, cargo_class: 'fcl_40_hq', load_type: 'container', carriage: 'on', location: destination_trucking_location, truck_type: 'chassis')
          FactoryBot.create(:legacy_local_charge, hub: shanghai, direction: 'export', load_type: 'fcl_40_hq', tenant_vehicle: tenant_vehicle, tenant: legacy_tenant)
          FactoryBot.create(:legacy_local_charge, hub: hamburg, direction: 'import', load_type: 'fcl_40_hq', tenant_vehicle: tenant_vehicle, tenant: legacy_tenant)
          FactoryBot.create(:fcl_pre_carriage_availability, hub: shanghai, query_type: :location, custom_truck_type: 'chassis')
          FactoryBot.create(:fcl_on_carriage_availability, hub: hamburg, query_type: :location, custom_truck_type: 'chassis')
          Geocoder::Lookup::Test.add_stub([hamburg_address.latitude, hamburg_address.longitude], [
                                            'address_components' => [{ 'types' => ['premise'] }],
                                            'address' => 'Brooktorkai 7, Hamburg, 20457, Germany',
                                            'city' => 'Hamburg',
                                            'country' => 'Germany',
                                            'country_code' => 'DE',
                                            'postal_code' => '20457'
                                          ])
          Geocoder::Lookup::Test.add_stub([shanghai_address.latitude, shanghai_address.longitude], [
                                            'address_components' => [{ 'types' => ['premise'] }],
                                            'address' => 'Shanghai, China',
                                            'city' => 'Shanghai',
                                            'country' => 'China',
                                            'country_code' => 'CN',
                                            'postal_code' => '210001'
                                          ])
        end

        let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
        let(:hamburg_address) { FactoryBot.create(:hamburg_address) }
        let(:destination_location) do
          FactoryBot.create(:locations_location,
                            bounds: FactoryBot.build(:legacy_bounds, lat: hamburg_address.latitude, lng: hamburg_address.longitude, delta: 0.4),
                            country_code: 'de')
        end
        let(:origin_location) do
          FactoryBot.create(:locations_location,
                            bounds: FactoryBot.build(:legacy_bounds, lat: shanghai_address.latitude, lng: shanghai_address.longitude, delta: 0.4),
                            country_code: 'cn')
        end
        let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: 'CN') }
        let(:destination_trucking_location) { FactoryBot.create(:trucking_location, location: destination_location, country_code: 'DE') }
        let(:origin) { { latitude: shanghai_address.latitude, longitude: shanghai_address.longitude } }
        let(:destination) { { latitude: hamburg_address.latitude, longitude: hamburg_address.longitude } }

        it 'returns all the cargo classes for all itineraries for origin and destination' do
          results = described_class.new(user: user, origin: origin, destination: destination).perform
          expect(results).to match_array(%w[fcl_40_hq])
        end
      end

      context 'with dedicated_pricings_only' do
        before do
          FactoryBot.create(:tenants_group, tenant: tenant).tap do |tapped_group|
            FactoryBot.create(:tenants_membership, member: user, group: tapped_group)
            FactoryBot.create(:pricings_pricing, tenant: legacy_tenant, group_id: tapped_group.id, cargo_class: 'test', load_type: 'container', itinerary: itinerary)
          end
        end

        it 'returns all the cargo classes for all itineraries with group pricings' do
          results = described_class.new(user: user, dedicated_pricings_only: true).perform
          expect(results).to match_array(%w[test])
        end
      end
    end
  end
end
