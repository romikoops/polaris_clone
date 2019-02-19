require 'rails_helper'
require 'timecop'
module Trucking
  RSpec.describe Rate, type: :model do
    context 'class methods' do
      describe '.find_by_filter' do
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
  
        context 'basic tests' do
          it 'raises an ArgumentError if no load_type is provided' do
            expect do
              trucking_rates = described_class.find_by_filter(
                tenant_id: tenant.id, zipcode: zipcode, carriage: carriage, country_code: country_code
              )
            end.to raise_error(ArgumentError)
          end
  
          it 'raises an ArgumentError if no tenant_id is provided' do
            expect do
              trucking_rates = described_class.find_by_filter(
                load_type: load_type, zipcode: zipcode, carriage: carriage, country_code: country_code
              )
            end.to raise_error(ArgumentError)
          end
  
          it 'raises an ArgumentError if no carriage is provided' do
            expect do
              trucking_rates = described_class.find_by_filter(
                tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, country_code: country_code
              )
            end.to raise_error(ArgumentError)
          end
  
          it 'raises an ArgumentError if no country_code is provided' do
            expect do
              trucking_rates = described_class.find_by_filter(
                tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
              )
            end.to raise_error(ArgumentError)
          end
        end
  
        context 'zipcode identifier' do
          let!(:trucking_trucking_zipcode) do
            FactoryBot.create(:trucking_trucking,
                   hub: hub,
                   location: trucking_location_zipcode,
                   rate: trucking_rate)
          end
  
          it 'finds the correct trucking_rate with avulsed address filters' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              zipcode: zipcode
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'finds the correct trucking_rate with address object filter' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'finds the correct trucking_rate with cargo_class filter' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address, cargo_class: 'lcl'
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'return empty collection if cargo_class filter does not match any item in db' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address, cargo_class: 'some_string'
            )
  
            expect(trucking_rates).to match([])
          end
        end
  
        context 'geometry identifier' do
          let!(:trucking_trucking_geometry) do
            FactoryBot.create(:trucking_trucking,
                   hub: hub,
                   location: trucking_location_geometry,
                   rate: trucking_rate)
          end
  
          it 'finds the correct trucking_rate with avulsed address filters' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              latitude: latitude,   longitude: longitude
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'finds the correct trucking_rate with address object filter' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'finds the correct trucking_rate with cargo_class filter' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address, cargo_class: 'lcl'
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'return empty collection if cargo_class filter does not match any item in db' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address, cargo_class: 'some_string'
            )
  
            expect(trucking_rates).to match([])
          end
        end
  
        context 'distance identifier' do
          let!(:trucking_trucking_distance) do
            FactoryBot.create(:trucking_trucking,
                   hub: hub,
                   location: trucking_location_distance,
                   rate: trucking_rate)
          end
  
          it 'finds the correct trucking_rate with avulsed address filters', pending: 'Outdated spec' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              latitude: latitude,   longitude: longitude
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'finds the correct trucking_rate with address object filter', pending: 'Outdated spec' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'finds the correct trucking_rate with cargo_class filter', pending: 'Outdated spec' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address, cargo_class: 'lcl'
            )
  
            expect(trucking_rates).to match([trucking_rate])
          end
  
          it 'return empty collection if cargo_class filter does not match any item in db' do
            trucking_rates = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
              address: address, cargo_class: 'some_string'
            )
  
            expect(trucking_rates).to match([])
          end
        end
      end
  
      describe '.find_by_hub_id' do
        let(:tenant) { FactoryBot.create(:legacy_tenant) }
        let(:hub)    { FactoryBot.create(:legacy_hub, :with_lat_lng, tenant: tenant) }
  
        let(:courier)          { FactoryBot.create(:trucking_courier) }
        let(:trucking_rate) { FactoryBot.create(:trucking_rate, tenant: tenant) }
  
        context 'basic tests' do
          it 'raises an ArgumentError if no hub_id are provided' do
            expect do
              described_class.find_by_hub_id
            end.to raise_error(ArgumentError)
          end
  
          it 'returns empty array if no pricings were found' do
            FactoryBot.create(:trucking_trucking,
                   hub: hub,
                   location: FactoryBot.create(:trucking_location, :with_location),
                   rate: trucking_rate)
            expect(described_class.find_by_hub_id(-1)).to eq([])
          end
        end
  
        context 'zipcode identifier' do
          it 'finds the correct pricing and destinations' do
            FactoryBot.create_list(:trucking_location, 100, :zipcode_sequence).each do |trucking_location|
              FactoryBot.create(:trucking_trucking,
                     hub: hub,
                     location: trucking_location,
                     rate: trucking_rate)
            end
  
            trucking_rates = described_class.find_by_hub_id(hub.id)
  
            expect(trucking_rates.first).to include('zipcode' => [%w(15000 15099)], 'countryCode' => 'SE')
            expect(trucking_rates.first['truckingPricing']).to include(trucking_rate.as_options_json.except('FactoryBot.created_at', 'updated_at'))
          end
  
          it 'finds the correct pricing and destinations for multiple range groups per zone' do
            Timecop.freeze(Time.now) do
              FactoryBot.create_list(:trucking_location, 100, :zipcode_broken_sequence).each do |trucking_location|
                FactoryBot.create(:trucking_trucking,
                       hub: hub,
                       location: trucking_location,
                       rate: trucking_rate)
              end
  
              trucking_rates = described_class.find_by_hub_id(hub.id)
  
              expect(trucking_rates.first).to include('zipcode' => [%w(15000 15039), %w(15050 15109)], 'countryCode' => 'SE')
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
  
              trucking_rates = described_class.find_by_hub_id(hub.id)
  
              expect(trucking_rates.first).to include('city' => [%w(Gothenburg Sweden)], 'countryCode' => 'SE')
              expect(trucking_rates.first['truckingPricing']).to include(trucking_rate.as_options_json.except('FactoryBot.created_at', 'updated_at'))
            end
          end
        end
      end
    end
  end
end
