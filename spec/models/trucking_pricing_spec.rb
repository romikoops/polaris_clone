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

    	let(:courier)          { create(:courier) }
      let(:trucking_pricing) { create(:trucking_pricing, courier: courier, tenant: tenant) }


      let(:zipcode)      { '15211' }
      let(:latitude)     { '57.000000' }
      let(:longitude)    { '11.100000' }
      let(:load_type)    { 'cargo_item' }
      let(:carriage)     { 'pre' }
      let(:country_code) { 'SE' }

      let(:location) {
        create(:location, zip_code: zipcode, latitude: latitude, longitude: longitude)
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

        it 'raises an ArgumentError if no filter besides mandatory arguments is provided' do
          expect {
            trucking_pricings = described_class.find_by_filter(
              tenant_id: tenant.id, load_type: load_type,
              carriage: carriage,   country_code: country_code,
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

        it 'finds the correct trucking_pricing with avulsed location filters' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            zipcode: zipcode,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with location object filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with cargo_class filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,   cargo_class: 'fcl_20f'
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,   cargo_class: 'some_string'
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
        it 'finds the correct trucking_pricing with avulsed location filters' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            latitude: latitude,   longitude: longitude
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with location object filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with cargo_class filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,   cargo_class: 'fcl_20f'
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,   cargo_class: 'some_string'
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
        it 'finds the correct trucking_pricing with avulsed location filters' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            latitude: latitude,   longitude: longitude
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'finds the correct trucking_pricing with location object filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end
        
        it 'finds the correct trucking_pricing with cargo_class filter' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,   cargo_class: 'fcl_20f'
          )

          expect(trucking_pricings).to match([trucking_pricing])
        end

        it 'return empty collection if cargo_class filter does not match any item in db' do
          trucking_pricings = described_class.find_by_filter(
            tenant_id: tenant.id, load_type: load_type,
            carriage: carriage,   country_code: country_code,
            location: location,   cargo_class: 'some_string'
          )

          expect(trucking_pricings).to match([])
        end
      end
    end

    describe '.find_by_hub_ids' do
      let(:tenant) { create(:tenant) }
      let(:hub)    { create(:hub, :with_lat_lng, tenant: tenant) }

      let(:courier)          { create(:courier) }
      let(:trucking_pricing) { create(:trucking_pricing, courier: courier, tenant: tenant) }

      context 'basic tests' do
        it 'raises an ArgumentError if no tenant_id is provided' do         
          expect {
            described_class.find_by_hub_ids(hub_ids: [hub.id])
          }.to raise_error(ArgumentError)
        end 

        it 'raises an ArgumentError if no hub_ids are provided' do         
          expect {
            described_class.find_by_hub_ids(tenant_id: tenant.id)
          }.to raise_error(ArgumentError)
        end
      end      

      context 'main tests' do
        it 'finds the correct pricing' do         
          create_list(:trucking_destination, 100, :zipcode_sequence).each do |trucking_destination|
            create(:hub_trucking,
              hub:                  hub,
              trucking_destination: trucking_destination,
              trucking_pricing:     trucking_pricing
            )
          end

          trucking_pricings = described_class.find_by_hub_ids(
            hub_ids: [hub.id], tenant_id: tenant.id
          )

          expect(trucking_pricings).to match([
            {
              "truckingPricing" => trucking_pricing,
              "zipcode"         => ["15000", "15099"]          
            }
          ])
        end
      end      
    end
  end
end
