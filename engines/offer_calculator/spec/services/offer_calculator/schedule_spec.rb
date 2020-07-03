# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::Schedule do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, :with_trip, organization: organization) }
  let!(:trip) { itinerary.trips.first }
  let(:origin_hub) { itinerary.origin_hub }
  let(:destination_hub) { itinerary.destination_hub }
  let(:routes) do
    [
      OfferCalculator::Route.new(
        itinerary_id: itinerary.id,
        origin_stop_id: itinerary.origin_stops.first.id,
        destination_stop_id: itinerary.destination_stops.first.id,
        tenant_vehicle_id: trip.tenant_vehicle_id,
        carrier_id: trip.tenant_vehicle&.carrier_id
      )
    ]
  end
  let(:current_etd) { 2.days.from_now }
  let(:required_keys) do
    %i[
      id
      mode_of_transport
      eta
      etd
      closing_date
      vehicle_name
      carrier_name
      trip_id
      origin_hub
      destination_hub
      transshipment
    ]
  end

  context 'class methods' do
    describe '.from_routes', :vcr do
      it 'returns the schedules for the route' do
        results = described_class.from_routes(routes, current_etd, 60, 'cargo_item', 'depature')
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.trip).to eq(trip)
        end
      end
    end

    describe '.from_trips', :vcr do
      it 'returns a hash of schedule values' do
        results = described_class.from_trips([trip])
        aggregate_failures do
          expect(results.length).to eq(1)
          expect(results.first.keys).to match_array(required_keys)
        end
      end
    end
  end

  context 'instance methods' do
    let(:schedule) { described_class.from_trip(trip) }

    describe '.hub_for_carriage', :vcr do
      it 'returns the origin hub' do
        expect(schedule.hub_for_carriage('pre')).to eq(origin_hub)
      end

      it 'returns the destination hub' do
        expect(schedule.hub_for_carriage('on')).to eq(destination_hub)
      end

      it 'raises an argument error' do
        expect { schedule.hub_for_carriage('blue') }.to raise_error(ArgumentError)
      end
    end
  end
end
