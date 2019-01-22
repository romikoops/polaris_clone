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
  let(:cargo_object) do
    {
      'stackable' => {
        'volume' => 0,
        'weight' => 0,
        'number_of_items' => 0
      }, 'non_stackable' => {
        'volume' => 0,
        'weight' => 0,
        'number_of_items' => 0
      }
    }
  end

  describe '.calc_aggregated_cargo_cbm_ratio' do
    it 'calculates the correct trucking weight for aggregate cargo with vol gt weight' do
      aggregated_cargo = create(:aggregated_cargo, shipment_id: shipment.id, volume: 3.0, weight: 1500)
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 1000)

      described_class.calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, aggregated_cargo)
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end
    it 'calculates the correct trucking weight for aggregate cargo with weight gt vol' do
      aggregated_cargo = create(:aggregated_cargo, shipment_id: shipment.id, volume: 1.5, weight: 3000)
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 1000)

      described_class.calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, aggregated_cargo)
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end
  end

  describe '.get_cargo_item_object' do
    it 'correctly consolidates the cargo values for scope consolidation.trucking.calculation' do
      cargo_1 = create(:cargo_item,
                       shipment_id: shipment.id,
                       dimension_x: 120,
                       dimension_y: 80,
                       dimension_z: 140,
                       payload_in_kg: 200,
                       quantity: 1)
      cargo_2 = create(:cargo_item,
                       shipment_id: shipment.id,
                       dimension_x: 120,
                       dimension_y: 80,
                       dimension_z: 150,
                       payload_in_kg: 400,
                       quantity: 2)
      tenant.scope['consolidation'] = {
        'trucking' => {
          'calculation' => true
        }
      }
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 250, load_meterage: {}, tenant: tenant)
      cargo_object = described_class.get_cargo_item_object(trucking_pricing, [cargo_1, cargo_2])
      expect(cargo_object['stackable']['weight']).to eq(1056)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.calculation with agg cargo' do
      aggregated_cargo = create(:aggregated_cargo, shipment_id: shipment.id, volume: 1.5, weight: 3000)

      tenant.scope['consolidation'] = {
        'trucking' => {
          'calculation' => true
        }
      }
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 250, load_meterage: {}, tenant: tenant)
      cargo_object = described_class.get_cargo_item_object(trucking_pricing, [aggregated_cargo])
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only' do
      cargo_1 = create(:cargo_item,
                       shipment_id: shipment.id,
                       dimension_x: 120,
                       dimension_y: 80,
                       dimension_z: 140,
                       payload_in_kg: 200,
                       quantity: 1)
      cargo_2 = create(:cargo_item,
                       shipment_id: shipment.id,
                       dimension_x: 120,
                       dimension_y: 80,
                       dimension_z: 150,
                       payload_in_kg: 400,
                       quantity: 2)
      tenant.scope['consolidation'] = {
        'trucking' => {
          'load_meterage_only' => true
        }
      }
      trucking_pricing = create(:trucking_pricing, cbm_ratio: 250, load_meterage: {}, tenant: tenant)
      cargo_object = described_class.get_cargo_item_object(trucking_pricing, [cargo_1, cargo_2])
      expect(cargo_object['stackable']['weight']).to eq(1136)
    end
  end
end
