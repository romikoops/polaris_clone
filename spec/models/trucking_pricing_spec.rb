# frozen_string_literal: true

require 'rails_helper'

describe TruckingPricing, type: :model do
  context 'class methods' do
    describe '.find_by_filter' do
      let(:tenant) { create(:tenant) }
    	let(:hub)    { create(:hub, :with_lat_lng, tenant: tenant) }

    	let(:trucking_destination_zipcode) 	 { create(:trucking_destination, :zipcode) }
    	let(:trucking_destination_city_name) { create(:trucking_destination, :city_name) }
    	let(:trucking_destination_distance)  { create(:trucking_destination, :distance) }

    	let(:courier)          { create(:courier) }
      let(:trucking_pricing) { create(:trucking_pricing, courier: courier, tenant: tenant) }

    	let(:hub_trucking_zipcode) {
    		create(:hub_trucking,
    			hub: 									hub,
    			trucking_destination: trucking_destination_zipcode,
    			trucking_pricing: 		trucking_pricing
    		)
    	}
    	let(:hub_trucking_city_name) {
    		create(:hub_trucking,
    			hub: 									hub,
    			trucking_destination: trucking_destination_city_name,
    			trucking_pricing: 		trucking_pricing
    		)
    	}
    	let(:hub_trucking_distance) {
    		create(:hub_trucking,
    			hub: 									hub,
    			trucking_destination: trucking_destination_distance,
    			trucking_pricing: 		trucking_pricing
    		)
    	}

      let(:zipcode)   { '15211' }
      let(:city_name) { 'Gothenburg' }
      let(:latitude)  { '57.000000' }
      let(:longitude) { '11.100000' }
      let(:load_type) { 'cargo_item' }
      let(:carriage)  { 'pre' }

      context 'basic tests' do
      	it 'raises an ArgumentError if no load_type is provided' do      		
        	expect {
	        	trucking_pricings = described_class.find_by_filter(
		      		tenant_id: tenant.id, zipcode: zipcode, carriage: carriage
		      	)
        	}.to raise_error(ArgumentError)
      	end 

      	it 'raises an ArgumentError if no tenant_id is provided' do      		
        	expect {
	        	trucking_pricings = described_class.find_by_filter(
		      		load_type: load_type, zipcode: zipcode, carriage: carriage
		      	)
        	}.to raise_error(ArgumentError)
      	end 

        it 'raises an ArgumentError if no carriage is provided' do
        	expect {
	        	trucking_pricings = described_class.find_by_filter(
		      		tenant_id: tenant.id, zipcode: zipcode, load_type: load_type
		      	)
        	}.to raise_error(ArgumentError)
        end


        it 'returns a TruckingPricing::ActiveRecord_Relation' do
      		hub_trucking_zipcode.save!
        	
        	trucking_pricings = described_class.find_by_filter(
	      		tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
	      	)

          expect(trucking_pricings.class.to_s).to eq("TruckingPricing::ActiveRecord_Relation")
        end
      end

      context 'zipcode identifier' do
        it 'finds the correct trucking_pricing' do
      		hub_trucking_zipcode.save!

        	trucking_pricings = described_class.find_by_filter(
	      		tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
	      	)

          expect(trucking_pricings.last).to eq(trucking_pricing)
        end
      end

      context 'city_name identifier' do
        it 'finds the correct trucking_pricing' do
      		hub_trucking_city_name.save!

        	trucking_pricings = described_class.find_by_filter(
	      		tenant_id: tenant.id, city_name: city_name, load_type: load_type, carriage: carriage
	      	)

          expect(trucking_pricings.last).to eq(trucking_pricing)
        end
      end

      context 'distance identifier' do
        it 'finds the correct trucking_pricing' do
      		hub_trucking_distance.save!

        	trucking_pricings = described_class.find_by_filter(
	      		tenant_id: tenant.id, load_type: load_type, carriage: carriage,
	      		latitude: latitude, longitude: longitude
	      	)

          expect(trucking_pricings.last).to eq(trucking_pricing)
        end
      end
    end
  end

end
