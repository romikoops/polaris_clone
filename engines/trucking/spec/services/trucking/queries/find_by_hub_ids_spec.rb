# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Trucking::Queries::FindByHubIds do
  describe '.perform' do
    let(:tenant) { FactoryBot.create(:legacy_tenant) }
    let(:hub) { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: tenant) }

    let(:trucking_location_zipcode) { FactoryBot.create(:trucking_location, :zipcode) }
    let(:trucking_location_geometry)  { FactoryBot.create(:trucking_location, :with_location) }
    let(:trucking_location_distance)  { FactoryBot.create(:trucking_location, :distance) }

    let(:trucking_rate) { FactoryBot.create(:trucking_rate, tenant: tenant) }

    let(:zipcode)      { '15211' }
    let(:latitude)     { '57.000000' }
    let(:longitude)    { '11.100000' }
    let(:load_type)    { 'cargo_item' }
    let(:carriage)     { 'pre' }
    let(:country_code) { 'SE' }

    let(:address) do
      FactoryBot.create(:legacy_address, zip_code: zipcode, latitude: latitude, longitude: longitude)
    end

    describe '.find_by_hub_id' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:hub)    { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: tenant) }

      let(:courier) { FactoryBot.create(:trucking_courier) }
      let(:trucking_rate) { FactoryBot.create(:trucking_rate, tenant: tenant) }

      context 'when basic tests' do
        it 'raises an ArgumentError if no hub_id are provided' do
          expect { described_class.new(hub_ids: [], klass: ::Trucking::Trucking) }.to raise_error(ArgumentError)
        end

        it 'returns empty array if no pricings were found' do
          FactoryBot.create(:trucking_trucking,
                            hub: hub,
                            location: FactoryBot.create(:trucking_location, :with_location),
                            rate: trucking_rate)
          expect(described_class.new(hub_ids: [-1], klass: ::Trucking::Trucking).perform).to eq([])
        end
      end

      context 'when zipcode identifier' do
        let(:trucking_location) { FactoryBot.create(:trucking_location, zipcode: '30001') }
        let!(:target) { FactoryBot.create(:trucking_trucking, hub: hub, location: trucking_location) }

        it 'finds the correct pricing and destinations' do
          query = described_class.new(hub_ids: [hub.id], klass: ::Trucking::Trucking)
          truckings = query.perform.map(&:as_index_result)
          aggregate_failures do
            expect(truckings.first['zipCode']).to eq('30001')
            expect(truckings.first['countryCode']).to eq('SE')
            expect(truckings.first['truckingPricing'].except('created_at', 'updated_at')).to include(target.as_json.except('created_at', 'updated_at'))
          end
        end
      end

      context 'when geometry identifier' do
        let!(:target) do
          FactoryBot.create(:trucking_trucking,
                            hub: hub,
                            location: FactoryBot.create(:trucking_location, :with_location))
        end
        let(:query) { described_class.new(hub_ids: [hub.id], klass: ::Trucking::Trucking) }

        it 'finds the correct pricing and destinations' do
          Timecop.freeze(Time.zone.now) do
            truckings = query.perform.map(&:as_index_result)
            aggregate_failures do
              expect(truckings.first['city']).to eq('Gothenburg')
              expect(truckings.first['countryCode']).to eq('SE')
              expect(truckings.first['truckingPricing'].except('created_at', 'updated_at')).to include(target.as_json.except('created_at', 'updated_at'))
            end
          end
        end
      end
    end
  end
end
