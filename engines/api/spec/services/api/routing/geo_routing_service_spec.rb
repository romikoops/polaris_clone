# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::Routing::GeoRoutingService, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:origin_hub) { itinerary.hubs.find_by(name: 'Gothenburg Port') }
  let(:destination_hub) { itinerary.hubs.find_by(name: 'Shanghai Port') }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: origin_hub.latitude, lng: origin_hub.longitude, delta: 0.4),
                      country_code: 'se')
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: destination_hub.latitude, lng: destination_hub.longitude, delta: 0.4),
                      country_code: 'cn')
  end
  let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: 'SE') }
  let(:destination_trucking_location) { FactoryBot.create(:trucking_location, location: destination_location, country_code: 'CN') }
  let(:query) { nil }
  let(:result) do
    described_class.nexuses(
      tenant: tenant,
      coordinates: { lat: lat, lng: lng },
      query: query,
      load_type: 'cargo_item',
      target: target
    )
  end

  before do
    FactoryBot.create(:felixstowe_shanghai_itinerary, tenant: legacy_tenant)
    FactoryBot.create(:hamburg_shanghai_itinerary, tenant: legacy_tenant)
    FactoryBot.create(:lcl_pre_carriage_availability, hub: origin_hub, query_type: :location)
    FactoryBot.create(:lcl_on_carriage_availability, hub: destination_hub, query_type: :location)
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: origin_hub, location: origin_trucking_location)
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: destination_hub, carriage: 'on', location: destination_trucking_location)
    Geocoder::Lookup::Test.add_stub([origin_hub.latitude, origin_hub.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Göteborg, Sweden',
                                      'city' => 'Gothenburg',
                                      'country' => 'Sweden',
                                      'country_code' => 'SE',
                                      'postal_code' => '43813'
                                    ])
    Geocoder::Lookup::Test.add_stub([destination_hub.latitude, destination_hub.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => 'Shanghai, China',
                                      'city' => 'Shanghai',
                                      'country' => 'China',
                                      'country_code' => 'CN',
                                      'postal_code' => '210001'
                                    ])
  end

  describe '.nexuses' do
    context 'when targeting the origin with destination lat lng' do
      let(:expected_results) do
        legacy_tenant.itineraries.map { |itin| itin.first_nexus.name }
      end
      let(:lat) { destination_hub.latitude }
      let(:lng) { destination_hub.longitude }
      let(:target) { :origin_destination }

      it 'Renders a json of origins for given a destination lat lng' do
        expect(result.pluck(:name)).to match_array(expected_results)
      end
    end

    context 'when targeting the origin with destination lat lng and query' do
      let(:lat) { destination_hub.latitude }
      let(:lng) { destination_hub.longitude }
      let(:query) { origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it 'Renders a json of origins for given a destination lat lng' do
        expect(result.pluck(:name)).to match_array([origin_hub.nexus.name])
      end
    end

    context 'when targeting the origin with destination lat lng and query and multiple hubs' do
      before do
        hub_name = origin_hub.name.split(' ').first + ' Airport'
        FactoryBot.create(:legacy_hub, name: hub_name, hub_type: 'air', nexus: origin_hub.nexus)
      end

      let(:lat) { destination_hub.latitude }
      let(:lng) { destination_hub.longitude }
      let(:query) { origin_hub.nexus.name.first(5) }
      let(:target) { :origin_destination }

      it 'Renders a json of origins for given a destination lat lng' do
        expect(result.pluck(:name)).to match_array([origin_hub.nexus.name])
      end
    end

    context 'when targeting the destination with origin lat lng' do
      let(:lat) { origin_hub.latitude }
      let(:lng) { origin_hub.longitude }
      let(:target) { :destination_origin }

      it 'Renders a json of destinations for given a origin lat lng' do
        expect(result.pluck(:name)).to match_array(destination_hub.nexus.name)
      end
    end
  end
end
