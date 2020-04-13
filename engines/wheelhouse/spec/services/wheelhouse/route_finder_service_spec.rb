# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::RouteFinderService, type: :service do
  let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
  let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
  let(:user) { FactoryBot.create(:tenants_user, tenant: tenant) }
  let!(:ocean_itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: legacy_tenant) }
  let(:gothenburg_port) { ocean_itinerary.origin_hub }
  let(:shanghai_port) { ocean_itinerary.destination_hub }
  let(:air_itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: 'air', tenant: legacy_tenant) }
  let(:gothenburg_airport) { air_itinerary.origin_hub }
  let(:shanghai_airport) { air_itinerary.destination_hub }
  let(:gothenburg_address) { FactoryBot.create(:gothenburg_address) }
  let(:shanghai_address) { FactoryBot.create(:shanghai_address) }
  let(:origin_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: gothenburg_address.latitude, lng: gothenburg_address.longitude, delta: 0.4),
                      country_code: 'se')
  end
  let(:destination_location) do
    FactoryBot.create(:locations_location,
                      bounds: FactoryBot.build(:legacy_bounds, lat: shanghai_address.latitude, lng: shanghai_address.longitude, delta: 0.4),
                      country_code: 'cn')
  end
  let(:origin_trucking_location) { FactoryBot.create(:trucking_location, location: origin_location, country_code: 'SE') }
  let(:destination_trucking_location) { FactoryBot.create(:trucking_location, location: destination_location, country_code: 'CN') }
  let(:result) do
    described_class.routes(
      user: user,
      origin: origin,
      destination: destination,
      load_type: 'cargo_item'
    )
  end

  before do
    FactoryBot.create(:lcl_pre_carriage_availability, hub: gothenburg_port, query_type: :location)
    FactoryBot.create(:lcl_on_carriage_availability, hub: shanghai_port, query_type: :location)
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: gothenburg_port, location: origin_trucking_location)
    FactoryBot.create(:trucking_trucking, tenant: legacy_tenant, hub: shanghai_port, carriage: 'on', location: destination_trucking_location)
    Geocoder::Lookup::Test.add_stub([gothenburg_address.latitude, gothenburg_address.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => gothenburg_address.geocoded_address,
                                      'city' => gothenburg_address.city,
                                      'country' => gothenburg_address.country.name,
                                      'country_code' => gothenburg_address.country.code,
                                      'postal_code' => gothenburg_address.zip_code
                                    ])
    Geocoder::Lookup::Test.add_stub([shanghai_address.latitude, shanghai_address.longitude], [
                                      'address_components' => [{ 'types' => ['premise'] }],
                                      'address' => shanghai_address.geocoded_address,
                                      'city' => shanghai_address.city,
                                      'country' => shanghai_address.country.name,
                                      'country_code' => shanghai_address.country.code,
                                      'postal_code' => shanghai_address.zip_code
                                    ])
  end

  describe '.perform' do
    context 'with origin and destination nexus ids' do
      let(:origin) { { nexus_id: gothenburg_port.nexus_id } }
      let(:destination) { { nexus_id: shanghai_port.nexus_id } }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([ocean_itinerary, air_itinerary])
      end
    end

    context 'with origin nexus id and destination lat lng' do
      let(:origin) { { id: gothenburg_port.nexus_id } }
      let(:destination) { { latitude: shanghai_address.latitude, longitude: shanghai_address.longitude } }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([ocean_itinerary])
      end
    end

    context 'with origin and destination lat/lngs' do
      let(:origin) { { latitude: gothenburg_address.latitude, longitude: gothenburg_address.longitude } }
      let(:destination) { { latitude: shanghai_address.latitude, longitude: shanghai_address.longitude } }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([ocean_itinerary])
      end
    end

    context 'without origin and destination' do
      let(:origin) { {} }
      let(:destination) { {} }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([])
      end
    end
  end
end
