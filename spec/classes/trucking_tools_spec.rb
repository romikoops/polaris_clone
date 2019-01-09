# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TruckingTools do

  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { create(:tenant) }
  let(:trip) { create(:trip) }
  let(:user) { create(:user, tenant: tenant) }
  let(:shipment) { create(:shipment, load_type: load_type, direction: direction, user: user, tenant: tenant, origin_nexus: origin_nexus, destination_nexus: destination_nexus, trip: itinerary.trips.first, itinerary: itinerary) }
  let(:origin_nexus) { create(:nexus, hubs: [origin_hub]) }
  let(:destination_nexus) { create(:nexus, hubs: [destination_hub]) }
  let!(:itinerary) { create(:itinerary, tenant: tenant, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: [trip]) }
  let(:origin_hub) { create(:hub, tenant: tenant) }
  let(:destination_hub) { create(:hub, tenant: tenant) }
  let(:origin_stop) { create(:stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { create(:stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { create(:layover, stop_index: 0, trip: trip) }
  let(:destination_layover) { create(:layover, stop_index: 1, trip: trip) }

  describe '.calc_aggregated_cargo_cbm_ratio' do
    it 'calculates the correct trucking weight for aggregate cargo with vol gt weight' do
      cargo_object = {
        'stackable' => {
          'volume'          => 0,
          'weight'          => 0,
          'number_of_items' => 0
        }, 'non_stackable' => {
          'volume'          => 0,
          'weight'          => 0,
          'number_of_items' => 0
        }
      }

      aggregated_cargo = create(:aggregated_cargo, shipment_id: shipment.id, volume: 3.0, weight: 1500)
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 1000)

      TruckingTools.calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, aggregated_cargo)
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end
    it 'calculates the correct trucking weight for aggregate cargo with weight gt vol' do
      cargo_object = {
        'stackable' => {
          'volume'          => 0,
          'weight'          => 0,
          'number_of_items' => 0
        }, 'non_stackable' => {
          'volume'          => 0,
          'weight'          => 0,
          'number_of_items' => 0
        }
      }

      aggregated_cargo = create(:aggregated_cargo, shipment_id: shipment.id, volume: 1.5, weight: 3000)
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 1000)

      TruckingTools.calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, aggregated_cargo)
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end
  end
end
