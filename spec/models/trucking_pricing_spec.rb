# frozen_string_literal: true

require 'rails_helper'

describe TruckingPricing, type: :model do
  context 'class methods' do
    describe '.find_by_filter' do
      let(:tenant)               { create(:tenant) }
    	let(:hub)                  { create(:hub, tenant: tenant) }

    	let(:trucking_destination) { create(:trucking_destination, :zipcode) }

    	let(:courier)          { create(:courier) }
      let(:trucking_pricing) { create(:trucking_pricing, courier: courier, tenant: tenant) }

    	let(:hub_trucking) {
    		create(:hub_trucking,
    			hub: 									hub,
    			trucking_destination: trucking_destination,
    			trucking_pricing: 		trucking_pricing
    		)
    	}

      let(:zipcode)   { '15211' }
      let(:load_type) { 'cargo_item' }
      let(:carriage)  { 'pre' }

      context 'zipcode identifier' do
        it 'returns a TruckingPricing::ActiveRecord_Relation' do
        	trucking_pricings = described_class.find_by_filter(
	      		tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
	      	)

          expect(trucking_pricings.class.to_s).to eq("TruckingPricing::ActiveRecord_Relation")
        end

        it 'finds the correct trucking_pricing' do
        	hub_trucking.save!

        	trucking_pricings = described_class.find_by_filter(
	      		tenant_id: tenant.id, zipcode: zipcode, load_type: load_type, carriage: carriage
	      	)

          expect(trucking_pricings.last).to eq(trucking_pricing)
        end
      end
    end
  end

end
