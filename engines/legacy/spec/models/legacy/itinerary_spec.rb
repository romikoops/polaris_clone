# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Itinerary, type: :model do
    describe '.parse_load_type' do
      it 'returns the cargo_item for lcl' do
        itinerary = FactoryBot.create(:default_itinerary)
        expect(itinerary.parse_load_type('lcl')).to eq('cargo_item')
      end

      it 'returns the container for fcl' do
        itinerary = FactoryBot.create(:default_itinerary)
        expect(itinerary.parse_load_type('fcl')).to eq('container')
      end
    end

    describe '.destination_hub_ids' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:o_hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
      let(:d_hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
      let(:itinerary) do
        FactoryBot.create(:default_itinerary,
          tenant: tenant,
          stops: [
            FactoryBot.build(:legacy_stop, hub: o_hub, index: 0),
            FactoryBot.build(:legacy_stop, hub: d_hub, index: 1)
          ]
        )
      end
      it 'returns the hub ids for the destination' do
        expect(itinerary.destination_hub_ids).to eq([d_hub.id])
      end
    end

    describe '.default_generate_schedules' do
      let(:tenant) { FactoryBot.create(:legacy_tenant) }
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, tenant: tenant) }
      let!(:lcl_pricing) { FactoryBot.create(:legacy_lcl_pricing, itinerary: itinerary) }
      let!(:fcl_20_pricing) { FactoryBot.create(:legacy_fcl_20_pricing, itinerary: itinerary) }

      context 'without existing trips' do
        before do
          itinerary.default_generate_schedules(end_date: Date.today + 10.days, base_pricing: false, sandbox: nil)
        end

        it 'generates trips for all the pricings' do
          aggregate_failures do
            expect(itinerary.trips.where(tenant_vehicle_id: lcl_pricing.tenant_vehicle_id).length).to be_positive
            expect(itinerary.trips.where(tenant_vehicle_id: fcl_20_pricing.tenant_vehicle_id).length).to be_positive
          end
        end
      end

      context 'with existing trips' do
        before do
          FactoryBot.create(:legacy_trip,
            itinerary: itinerary,
            tenant_vehicle_id: lcl_pricing.tenant_vehicle_id,
            load_type: 'cargo_item'
          )
          FactoryBot.create(:legacy_trip,
            itinerary: itinerary,
            tenant_vehicle_id: fcl_20_pricing.tenant_vehicle_id,
            load_type: 'conatiner'
          )
        end

        it 'generates trips for all the pricings' do
          itinerary.default_generate_schedules(end_date: Date.today + 10.days, base_pricing: false, sandbox: nil)
          aggregate_failures do
            expect(itinerary.trips.where(tenant_vehicle_id: lcl_pricing.tenant_vehicle_id).length).to be_positive
            expect(itinerary.trips.where(tenant_vehicle_id: fcl_20_pricing.tenant_vehicle_id).length).to be_positive
          end
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: itineraries
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  name              :string
#  transshipment     :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  tenant_id         :integer
#
# Indexes
#
#  index_itineraries_on_mode_of_transport  (mode_of_transport)
#  index_itineraries_on_name               (name)
#  index_itineraries_on_sandbox_id         (sandbox_id)
#  index_itineraries_on_tenant_id          (tenant_id)
#
