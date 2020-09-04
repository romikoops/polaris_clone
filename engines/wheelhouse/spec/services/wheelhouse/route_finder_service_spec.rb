# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Wheelhouse::RouteFinderService, type: :service do
  include_context 'complete_route_with_trucking'

  let(:load_type) { 'cargo_item' }
  let(:cargo_classes) { %w[lcl] }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:origin_hub) { itinerary.origin_hub }
  let(:air_itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, mode_of_transport: 'air', organization: organization) }
  let(:destination_airport) { air_itinerary.destination_hub }
  let(:result) do
    described_class.routes(
      organization: organization,
      user: user,
      origin: origin,
      destination: destination,
      load_type: load_type
    )
  end

  before do
    Organizations.current_id = organization.id
  end

  describe '.perform' do
    context 'with origin and destination nexus ids' do
      let(:origin) { { nexus_id: origin_hub.nexus_id } }
      let(:destination) { { nexus_id: destination_airport.nexus_id } }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([itinerary, air_itinerary])
      end
    end

    context 'with origin nexus id and destination lat lng' do
      let(:origin) { { nexus_id: origin_hub.nexus_id } }
      let(:destination) { { latitude: delivery_address.latitude, longitude: delivery_address.longitude } }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([itinerary])
      end
    end

    context 'with origin and destination lat/lngs' do
      let(:origin) { { latitude: pickup_address.latitude, longitude: pickup_address.longitude } }
      let(:destination) { { latitude: delivery_address.latitude, longitude: delivery_address.longitude } }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([itinerary])
      end
    end

    context 'without origin and destination' do
      let(:origin) { {} }
      let(:destination) { {} }

      it 'returns the itineraries between the origin & destination' do
        expect(result).to match_array([])
      end
    end

    context 'with only origin' do
      let(:origin) { { latitude: pickup_address.latitude, longitude: pickup_address.longitude } }
      let(:destination) { {} }

      it 'returns the itineraries for that origin' do
        expect(result).to match_array([itinerary])
      end
    end

    context 'with only destination' do
      let(:origin) { {} }
      let(:destination) { { latitude: delivery_address.latitude, longitude: delivery_address.longitude } }

      it 'returns the itineraries for that destination' do
        expect(result).to match_array([itinerary])
      end
    end
  end
end
