# frozen_string_literal: true

require 'rails_helper'

describe TruckingDestination, type: :model do
	context 'class methods' do
    describe '.find_via_distance_to_hub' do
    	let(:tenant) { create(:tenant) }
    	let(:hub) { create(:hub, :with_lat_lng, tenant: tenant) }
    	let(:trucking_destination)  { create(:trucking_destination, :distance) }

      let(:latitude)  { '57.000000' }
      let(:longitude) { '11.100000' }

      context 'basic tests' do
	    	it 'raises an ArgumentError if no hub is provided' do      		
	      	expect {
	      		_trucking_destination = described_class.find_via_distance_to_hub(
	      			latitude: latitude, longitude: longitude
	      		).first
	      	}.to raise_error(ArgumentError)
	    	end 

	    	it 'raises an ArgumentError if no latitude is provided' do      		
	      	expect {
	      		_trucking_destination = described_class.find_via_distance_to_hub(
	    				hub: hub, longitude: longitude
	      		).first
	      	}.to raise_error(ArgumentError)
	    	end 

	    	it 'raises an ArgumentError if no longitude is provided' do      		
	      	expect {
	      		_trucking_destination = described_class.find_via_distance_to_hub(
		    			hub: hub, latitude: latitude
	      		).first
	      	}.to raise_error(ArgumentError)
	    	end 
    	end 

      context 'main tests' do
	      it 'finds correct trucking destination ' do
	      	trucking_destination.save!
	    		_trucking_destination = described_class.find_via_distance_to_hub(
	    			hub: hub, latitude: latitude, longitude: longitude
	    		).first

	        expect(_trucking_destination).to eq(trucking_destination)
	      end
    	end 
    end
  end

end
