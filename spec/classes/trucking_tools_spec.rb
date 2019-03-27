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
  let!(:default_cargos) do
    [
      create(:cargo_item,
             shipment_id: shipment.id,
             dimension_x: 120,
             dimension_y: 80,
             dimension_z: 140,
             payload_in_kg: 200,
             quantity: 1),
      create(:cargo_item,
             shipment_id: shipment.id,
             dimension_x: 120,
             dimension_y: 80,
             dimension_z: 150,
             payload_in_kg: 400,
             quantity: 2)
    ]
  end
  let!(:ldm_cargo) do
      create(:cargo_item,
             shipment_id: shipment.id,
             dimension_x: 120,
             dimension_y: 80,
             dimension_z: 140,
             payload_in_kg: 200,
             quantity: 5)
  end

  let!(:consolidated_cargo) do
    {
      id: 'ids',
      dimension_x: 300,
      dimension_y: 240,
      dimension_z: 300,
      volume: 21.6,
      payload_in_kg: 4000,
      cargo_class: 'lcl',
      num_of_items: 3,
      quantity: 1
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

    it 'correctly consolidates the cargo values for scope consolidation.trucking.comparative' do
      cargos = [
        create(:cargo_item,
               shipment_id: shipment.id,
               dimension_x: 10,
               dimension_y: 15,
               dimension_z: 20,
               payload_in_kg: 30.0 / 45.0,
               quantity: 45),
        create(:cargo_item,
               shipment_id: shipment.id,
               dimension_x: 30,
               dimension_y: 30,
               dimension_z: 25,
               payload_in_kg: 36.0 / 15.0,
               quantity: 15),
        create(:cargo_item,
               shipment_id: shipment.id,
               dimension_x: 25,
               dimension_y: 25,
               dimension_z: 20,
               payload_in_kg: 168.0 / 32.0,
               quantity: 32)
      ]
      tenant.scope['consolidation'] = {
        'trucking' => {
          'comparative' => true
        }
      }
      trucking_pricing = create(:trucking_pricing,
                                cbm_ratio: 200,
                                load_meterage: {
                                  ratio: 1000,
                                  area: 48_000
                                },
                                tenant: tenant)
      cargo_object = described_class.get_cargo_item_object(trucking_pricing, cargos)
      expect(cargo_object['stackable']['weight'].to_i).to eq(234)
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

  context 'value extractors' do
    describe '.trucking_payload_weight' do
      it 'correctly returns the combined payload weight of all items in item group' do
        payload_1 = described_class.trucking_payload_weight(default_cargos.first)
        payload_2 = described_class.trucking_payload_weight(default_cargos.last)
        expect(payload_1).to eq(200)
        expect(payload_2).to eq(800)
      end
    end

    describe '.cargo_volume' do
      it 'correctly returns the combined volume of all items in item group' do
        volume_1 = described_class.cargo_volume(default_cargos.first)
        volume_2 = described_class.cargo_volume(default_cargos.last)
        expect(volume_1).to eq(1.344)
        expect(volume_2).to eq(2.88)
      end
    end

    describe '.cargos_volume' do
      it 'correctly returns the combined volume of all items in item groups' do
        volume_1 = described_class.cargos_volume(default_cargos)
        expect(volume_1).to eq(4.224)
      end
    end

    describe '.cargo_quantity' do
      it 'correctly returns the quantity of an item' do
        quantity = described_class.cargo_quantity(default_cargos.last)
        expect(quantity).to eq(2)
      end
      it 'correctly returns the default quantity of1 for agg cargo' do
        agg_cargo = create(:aggregated_cargo, volume: 1.5, weight: 1000)
        quantity = described_class.cargo_quantity(agg_cargo)
        expect(quantity).to eq(1)
      end
    end

    describe '.cargo_data_value' do
      it 'correctly returns the dimension_x of an item' do
        dimension_x = described_class.cargo_data_value(:dimension_x, default_cargos.last)
        expect(dimension_x).to eq(120)
      end
      it 'correctly returns the dimension_x of an hash item' do
        dimension_x = described_class.cargo_data_value(:dimension_x, consolidated_cargo)
        expect(dimension_x).to eq(300)
      end
    end

    describe '.cargo_unit_volume' do
      it 'correctly returns the unit volume of all items in item group' do
        volume_1 = described_class.cargo_unit_volume(default_cargos.first)
        volume_2 = described_class.cargo_unit_volume(default_cargos.last)
        expect(volume_1).to eq(1.344)
        expect(volume_2).to eq(1.44)
      end
      it 'correctly returns the unit volume of agg cargo' do
        agg_cargo = create(:aggregated_cargo, volume: 1.5, weight: 1000)
        volume_1 = described_class.cargo_unit_volume(agg_cargo)
        expect(volume_1).to eq(1.5)
      end
    end

    describe '.trucking_cbm_weight' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = create(:trucking_pricing, cbm_ratio: 200)
        cbm_1 = described_class.trucking_cbm_weight(trucking_pricing, default_cargos.first)
        cbm_2 = described_class.trucking_cbm_weight(trucking_pricing, default_cargos.last)
        expect(cbm_1).to eq(268.8)
        expect(cbm_2).to eq(576)
      end

      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = create(:trucking_pricing, cbm_ratio: 200)
        agg_cargo = create(:aggregated_cargo, volume: 1.5, weight: 1000)
        cbm = described_class.trucking_cbm_weight(trucking_pricing, agg_cargo)
        expect(cbm).to eq(300)
      end
    end

    describe '.trucking_chargeable_weight_by_stacked_area' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = create(:trucking_pricing, load_meterage: { ratio: 1000 })
        tcw_1 = described_class.trucking_chargeable_weight_by_stacked_area(trucking_pricing, default_cargos.first)
        tcw_2 = described_class.trucking_chargeable_weight_by_stacked_area(trucking_pricing, default_cargos.last)
        expect(tcw_1).to eq(400)
        expect(tcw_2).to eq(800)
      end
    end

    describe '.trucking_chargeable_weight_by_height' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = create(:trucking_pricing, load_meterage: { ratio: 1000 })
        tcw_1 = described_class.trucking_chargeable_weight_by_height(trucking_pricing, default_cargos.first)
        tcw_2 = described_class.trucking_chargeable_weight_by_height(trucking_pricing, default_cargos.last)
        expect(tcw_1).to eq(400)
        expect(tcw_2).to eq(800)
      end
    end

    describe '.trucking_chargeable_weight_by_area' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = create(:trucking_pricing, load_meterage: { ratio: 1000 })
        tcw_1 = described_class.trucking_chargeable_weight_by_area(trucking_pricing, default_cargos.first)
        tcw_2 = described_class.trucking_chargeable_weight_by_area(trucking_pricing, default_cargos.last)
        expect(tcw_1).to eq(400)
        expect(tcw_2).to eq(800)
      end
    end

    describe '.calc_cargo_load_meterage_height' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = create(:trucking_pricing, load_meterage: { ratio: 1000, height: 130 })
        result_object = described_class.calc_cargo_load_meterage_height(trucking_pricing, cargo_object, default_cargos.first)

        expect(result_object.dig('non_stackable', 'weight')).to eq(618.24)
        expect(result_object.dig('non_stackable', 'volume')).to eq(1.344)
        expect(result_object.dig('non_stackable', 'number_of_items')).to eq(1)
      end
    end

    describe '.calc_cargo_load_meterage_area' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = create(:trucking_pricing, load_meterage: { ratio: 1000, area: 48000 })
        result_object = described_class.calc_cargo_load_meterage_area(trucking_pricing, cargo_object, ldm_cargo)

        expect(result_object.dig('non_stackable', 'weight')).to eq(3091.2)
        expect(result_object.dig('non_stackable', 'volume')).to eq(33.6)
        expect(result_object.dig('non_stackable', 'number_of_items')).to eq(5)
      end
    end
  end
end
