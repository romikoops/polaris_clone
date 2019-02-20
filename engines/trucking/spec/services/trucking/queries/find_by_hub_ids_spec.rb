# frozen_string_literal: true

module Trucking
  module Queries
    RSpec.describe FindByHubIds do
      context 'class methods' do
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
      
            let(:courier)          { FactoryBot.create(:trucking_courier) }
            let(:trucking_rate) { FactoryBot.create(:trucking_rate, tenant: tenant) }
      
            context 'basic tests' do
              it 'raises an ArgumentError if no hub_id are provided' do
                expect do
                  described_class.new(hub_ids: [], klass: Rate)
                end.to raise_error(ArgumentError)
              end
      
              it 'returns empty array if no pricings were found' do
                FactoryBot.create(:trucking_trucking,
                       hub: hub,
                       location: FactoryBot.create(:trucking_location, :with_location),
                       rate: trucking_rate)
                expect(described_class.new(hub_ids: [-1], klass: Rate).perform).to eq([])
              end
            end
      
            context 'zipcode identifier' do
              it 'finds the correct pricing and destinations' do
                start_zip = 20000
                for i in (1..100).to_a do
                  trucking_location = FactoryBot.create(:trucking_location, zipcode: start_zip + i)
                  FactoryBot.create(:trucking_trucking,
                    hub: hub,
                    location: trucking_location,
                    rate: trucking_rate)
                end
      
                query = described_class.new(hub_ids: [hub.id], klass: Rate)
                query.perform
                trucking_rates = query.deserialized_result
      
                expect(trucking_rates.first).to include('zipcode' => [%w(20001 20100)], 'countryCode' => 'SE')
                expect(trucking_rates.first['truckingPricing']).to include(trucking_rate.as_options_json.except('FactoryBot.created_at', 'updated_at'))
              end
      
              it 'finds the correct pricing and destinations for multiple range groups per zone' do
                Timecop.freeze(Time.now) do
                  [15000, 18000].each do |start_zip|
                    for i in (1..100).to_a do
                      trucking_location = FactoryBot.create(:trucking_location, zipcode: start_zip + i)
                      FactoryBot.create(:trucking_trucking,
                        hub: hub,
                        location: trucking_location,
                        rate: trucking_rate)
                    end
                  end
                  query = described_class.new(hub_ids: [hub.id], klass: Rate)
                  query.perform
                  trucking_rates = query.deserialized_result

                  expect(trucking_rates.first['zipcode']).to eq([["15001", "15100"], ["18001", "18100"]])
                  expect(trucking_rates.first['countryCode']).to eq('SE')
                  expect(trucking_rates.first['truckingPricing']).to include(trucking_rate.as_options_json.except('FactoryBot.created_at', 'updated_at'))
                end
              end
            end
      
            context 'geometry identifier' do
              it 'finds the correct pricing and destinations', pending: 'Outdated spec' do
                Timecop.freeze(Time.now) do
                  FactoryBot.create(:trucking_trucking,
                         hub: hub,
                         location: FactoryBot.create(:trucking_location, :with_location),
                         rate: trucking_rate)
      
                  query = described_class.new(hub_ids: [hub.id], klass: Rate)
                  query.perform
                  trucking_rates = query.deserialized_result
      
                  expect(trucking_rates.first).to include('city' => [%w(Gothenburg Sweden)], 'countryCode' => 'SE')
                  expect(trucking_rates.first['truckingPricing']).to include(trucking_rate.as_options_json.except('FactoryBot.created_at', 'updated_at'))
                end
              end
            end
          end
        end
      end
    end
  end
end
