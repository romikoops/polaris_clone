# frozen_string_literal: true

require 'rails_helper'

describe TruckingPricing, type: :model do
  context 'class methods' do
    describe '.find_by_filter' do
      let(:tenant) { create(:tenant) }
    	let(:hub)    { create(:hub, :with_lat_lng, tenant: tenant) }

    	let(:trucking_destination_zipcode) 	 { create(:trucking_destination, :zipcode) }
    	let(:trucking_destination_geometry)  { create(:trucking_destination, :with_geometry) }
    	let(:trucking_destination_distance)  { create(:trucking_destination, :distance) }

      let(:trucking_pricing) { create(:trucking_pricing, tenant: tenant) }

      let(:zipcode)      { '15211' }
      let(:latitude)     { '57.000000' }
      let(:longitude)    { '11.100000' }
      let(:load_type)    { 'cargo_item' }
      let(:carriage)     { 'pre' }
      let(:country_code) { 'SE' }

      let(:address) {
        create(:address, zip_code: zipcode, latitude: latitude, longitude: longitude)
      }

      context 'basic tests' do
        it 'raises an ArgumentError if no load_type is provided' do
          expect {
            trucking_pricings = described_class.find_by_filter(
              tenant_id: tenant.id, zipcode: zipcode, carriage: carriage, country_code: country_code
            )
          }.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no tenant_id is provided' do
          expect {
            trucking_pricings = described_class.find_by_filter(
              load_type: load_type, zipcode: zipcode, carriage: carriage, country_code: country_code
            )
          }.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no carriage is provided' do
          expect {
            trucking_pricings = described_class.find_by_filter(
              tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, country_code: country_code
            )
          }.to raise_error(ArgumentError)
        end

        it 'raises an ArgumentError if no country_code is provided' do
          expect {
            trucking_pricings = described_class.find_by_filter(
              tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
            )
          }.to raise_error(ArgumentError)
        end
      end

      context 'zipcode identifier' do
      	let!(:hub_trucking_zipcode) {
      		create(:hub_trucking,
            hub:                  hub,
            trucking_destination: trucking_destination_zipcode,
            trucking_pricing:     trucking_pricing
          )
        }

        it 'finds the correct trucking_pricing with avulsed address filters' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            zipcode: zipcode,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with address object filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with cargo_class filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,   cargo_class: 'lcl'
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,   cargo_class: 'some_string'
          )

          expect(trucking_pricings).to match([])
        end
      end

      context 'geometry identifier' do
        let!(:hub_trucking_geometry) {
          create(:hub_trucking,
            hub:                  hub,
            trucking_destination: trucking_destination_geometry,
            trucking_pricing:     trucking_pricing
          )
        }
        it 'finds the correct trucking_pricing with avulsed address filters' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            latitude: latitude,   longitude: longitude
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with address object filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with cargo_class filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,   cargo_class: 'lcl'
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,   cargo_class: 'some_string'
          )

          expect(trucking_pricings).to match([])
        end
      end

      context 'distance identifier' do
        let!(:hub_trucking_distance) {
          create(:hub_trucking,
            hub:                  hub,
            trucking_destination: trucking_destination_distance,
            trucking_pricing:     trucking_pricing
          )
        }
        it 'finds the correct trucking_pricing with avulsed address filters', pending: 'Outdated spec' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            latitude: latitude,   longitude: longitude
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with address object filter', pending: 'Outdated spec' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with cargo_class filter', pending: 'Outdated spec' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,   cargo_class: 'lcl'
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            address: address,   cargo_class: 'some_string'
          )

          expect(trucking_pricings).to match([])
        end
      end
    end

    describe '.find_by_hub_id' do
      let(:tenant) { create(:tenant) }
      let(:hub)    { create(:hub, :with_lat_lng, tenant: tenant) }

      let(:courier)          { create(:courier) }
      let(:trucking_pricing) { create(:trucking_pricing, tenant: tenant) }

      context 'basic tests' do
        it 'raises an ArgumentError if no hub_id are provided' do
          expect {
            described_class.find_by_hub_id()
          }.to raise_error(ArgumentError)
        end

        it 'returns empty array if no pricings were found' do
          create(:hub_trucking,
            hub:                  hub,
            trucking_destination: create(:trucking_destination, :with_geometry),
            trucking_pricing:     trucking_pricing
          )
          expect(described_class.find_by_hub_id(-1)).to eq([])
        end
      end

      context 'zipcode identifier' do
        it 'finds the correct pricing and destinations', pending: 'broken tests' do
          create_list(:trucking_destination, 100, :zipcode_sequence).each do |trucking_destination|
            create(:hub_trucking,
              hub:                  hub,
              trucking_destination: trucking_destination,
              trucking_pricing:     trucking_pricing
            )
          end

          trucking_pricings = described_class.find_by_hub_id(hub.id)

          expect(trucking_pricings).to match([
            {
              "truckingPricing" => trucking_pricing.as_options_json,
              "zipcode"         => [["15000", "15099"]],
              "countryCode"     => "SE"
            }
          ])
        end

        it 'finds the correct pricing and destinations for multiple range groups per zone', pending: 'broken tests' do
          create_list(:trucking_destination, 100, :zipcode_broken_sequence).each do |trucking_destination|
            create(:hub_trucking,
              hub:                  hub,
              trucking_destination: trucking_destination,
              trucking_pricing:     trucking_pricing
            )
          end

          trucking_pricings = described_class.find_by_hub_id(hub.id)

          expect(trucking_pricings).to match([
            {
              "truckingPricing" => trucking_pricing.as_options_json,
              "zipcode"         => [["15000", "15039"], ["15050", "15109"]],
              "countryCode"     => "SE"
            }
          ])
        end
      end

      context 'geometry identifier' do
        it 'finds the correct pricing and destinations', pending: 'broken tests' do
          create(:hub_trucking,
            hub:                  hub,
            trucking_destination: create(:trucking_destination, :with_geometry),
            trucking_pricing:     trucking_pricing
          )

          trucking_pricings = described_class.find_by_hub_id(hub.id)

          expect(trucking_pricings).to match([
            {
              "truckingPricing" => trucking_pricing.as_options_json,
              "city"            => [["Testname4", "Gothenburg"]],
              "countryCode"     => "SE"
            }
          ])
        end
      end
    end
  end
end
