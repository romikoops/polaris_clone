# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::GoogleDirections do
  let(:origin) { '53.5453188,10.000840899999957' }
  let(:destination) { '53.536975,9.918213' }
  let(:departure_time) { 1_576_540_800 }
  let(:departure_time_future) { 1_576_545_800 }

  before(:each) do
    stub_request(:get, 'https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=1576540800&destination=53.536975,9.918213&key=&language=en&mode=driving&origin=53.5453188,10.000840899999957&traffic_model=pessimistic')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: FactoryBot.create(:google_directions_response), headers: {})
    stub_request(:get, 'https://maps.googleapis.com/maps/api/directions/xml?alternative=false&departure_time=now&destination=53.536975,9.918213&key=&language=en&mode=driving&origin=53.5453188,10.000840899999957&traffic_model=pessimistic')
      .with(
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'User-Agent' => 'Ruby'
        }
      )
      .to_return(status: 200, body: FactoryBot.create(:google_directions_response), headers: {})
  end

  Timecop.freeze(Time.utc(2020, 1, 1, 0, 0, 0)) do
    context 'requests' do
      describe '.distance_in_km' do
        it 'returns the correct distance in km' do
          result = described_class.new(origin, destination, departure_time).distance_in_km
          expect(result).to eq(11.88)
        end
      end

      describe '.distance_in_km below limit departure time' do
        it 'returns the correct distance in km' do
          result = described_class.new(origin, destination, 100).distance_in_km
          expect(result).to eq(11.88)
        end
      end

      describe '.distance_in_km_with_suffix' do
        it 'returns the correct distance in km w/ suffix' do
          result = described_class.new(origin, destination, departure_time).distance_in_km_with_suffix
          expect(result).to eq('11.88 km')
        end
      end

      describe '.distance_in_miles' do
        it 'returns the correct distance in miles' do
          result = described_class.new(origin, destination, departure_time).distance_in_miles
          expect(result).to eq(7.38)
        end
      end

      describe '.distance_in_miles_with_suffix' do
        it 'returns the correct distance in miles w/ suffix' do
          result = described_class.new(origin, destination, departure_time).distance_in_miles_with_suffix
          expect(result).to eq('7.38 mi')
        end
      end

      describe '.driving_time_in_seconds' do
        it 'returns the correct value' do
          result = described_class.new(origin, destination, departure_time).driving_time_in_seconds
          expect(result).to eq(1317)
        end
      end

      describe '.driving_time_in_seconds_for_trucks' do
        it 'returns the correct driving time for trucks' do
          result = described_class.new(origin, destination, departure_time).driving_time_in_seconds_for_trucks(1317)
          expect(result).to eq(2107)
        end
      end

      describe '.driving_time_in_seconds_for_trucks (long distance)' do
        it 'returns the correct driving time for trucks' do
          result = described_class.new(origin, destination, departure_time).driving_time_in_seconds_for_trucks(1_317_000)
          expect(result).to eq(4_856_700)
        end
      end

      describe '.geocoded_start_address' do
        it 'returns the correct address' do
          result = described_class.new(origin, destination, departure_time).geocoded_start_address
          expect(result).to eq('Brooktorkai 7, 20457 Hamburg, Germany')
        end
      end

      describe '.geocoded_end_address' do
        it 'returns the correct address' do
          result = described_class.new(origin, destination, departure_time).geocoded_end_address
          expect(result).to eq('A7, Hamburg, Germany')
        end
      end

      describe '.reverse_geocoded_start_address' do
        it 'returns the correct lat lngs' do
          result = described_class.new(origin, destination, departure_time).reverse_geocoded_start_address
          expect(result).to eq([53.5452189, 10.0009247])
        end
      end

      describe '.reverse_geocoded_end_address' do
        it 'returns the correct lat lngs' do
          result = described_class.new(origin, destination, departure_time).reverse_geocoded_end_address
          expect(result).to eq([53.5397838, 9.9213259])
        end
      end

      describe '.set_departure_time' do
        it 'returns the departure_time if it is greater than one hour' do
          allow(Time).to receive(:now).and_return(Time.at(departure_time - 5000))

          target = described_class.new(origin, destination, departure_time)
          expect(target.departure_time).to eq(departure_time)
        end

        it 'returns the now it the departure time is less than one hour' do
          allow(DateTime).to receive(:now).and_return(Time.at(departure_time))

          target = described_class.new(origin, destination, departure_time)
          expect(target.departure_time).to eq('now')
        end
      end
    end
  end
end
