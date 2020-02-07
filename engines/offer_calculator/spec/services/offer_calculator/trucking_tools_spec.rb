# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::TruckingTools do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }
  let(:trip) { FactoryBot.create(:legacy_trip) }
  let(:user) { FactoryBot.create(:legacy_user, tenant: tenant) }
  let(:tenants_user) { ::Tenants::User.find_by(legacy_id: user.id) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, hubs: [destination_hub]) }
  let!(:itinerary) { FactoryBot.create(:legacy_itinerary, tenant: tenant, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: [trip]) }
  let!(:shipment) { FactoryBot.create(:legacy_shipment, load_type: load_type, direction: direction, user: user, tenant: tenant, origin_nexus: origin_nexus, destination_nexus: destination_nexus, trip: itinerary.trips.first, itinerary: itinerary) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, hubs: [origin_hub]) }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, tenant: tenant) }
  let(:origin_stop) { FactoryBot.create(:legacy_stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { FactoryBot.create(:legacy_stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { FactoryBot.create(:legacy_layover, stop_index: 0, trip: trip) }
  let(:destination_layover) { FactoryBot.create(:legacy_layover, stop_index: 1, trip: trip) }
  let(:default_trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, tenant: tenant) }
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
      FactoryBot.create(:legacy_cargo_item,
                        shipment_id: shipment.id,
                        dimension_x: 120,
                        dimension_y: 80,
                        dimension_z: 140,
                        payload_in_kg: 200,
                        quantity: 1),
      FactoryBot.create(:legacy_cargo_item,
                        shipment_id: shipment.id,
                        dimension_x: 120,
                        dimension_y: 80,
                        dimension_z: 150,
                        payload_in_kg: 400,
                        quantity: 2)
    ]
  end
  let!(:fcl_cargo) do
    FactoryBot.create(:legacy_container,
                      payload_in_kg: 1000,
                      shipment_id: shipment.id,
                      quantity: 1)
  end
  let!(:ldm_cargo) do
    FactoryBot.create(:legacy_cargo_item,
                      shipment_id: shipment.id,
                      dimension_x: 120,
                      dimension_y: 80,
                      dimension_z: 140,
                      payload_in_kg: 200,
                      quantity: 5)
  end
  let!(:outsized_cargo) do
    FactoryBot.create(:legacy_cargo_item,
                      shipment_id: shipment.id,
                      dimension_x: 240,
                      dimension_y: 160,
                      dimension_z: 230,
                      payload_in_kg: 1000,
                      quantity: 10)
  end
  let!(:mini_cargo) do
    FactoryBot.create(:legacy_cargo_item,
                      shipment_id: shipment.id,
                      dimension_x: 1,
                      dimension_y: 1,
                      dimension_z: 1,
                      payload_in_kg: 1,
                      quantity: 1)
  end
  let(:agg_cargo) { FactoryBot.create(:legacy_aggregated_cargo, volume: 1.5, weight: 1000, shipment: shipment) }

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
      aggregated_cargo = FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id, volume: 3.0, weight: 1500)
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 1000)

      described_class.new(trucking_pricing, [aggregated_cargo], 0, 'pre', user).calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, aggregated_cargo)
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end
    it 'calculates the correct trucking weight for aggregate cargo with weight gt vol' do
      aggregated_cargo = FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id, volume: 1.5, weight: 3000)
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 1000)

      described_class.new(trucking_pricing, [aggregated_cargo], 0, 'pre', user).calc_aggregated_cargo_cbm_ratio(trucking_pricing, cargo_object, aggregated_cargo)
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end
  end

  describe '.cargo_item_object' do
    it 'correctly consolidates the cargo values for scope consolidation.trucking.calculation' do
      cargo_1 = FactoryBot.create(:legacy_cargo_item,
                                  shipment_id: shipment.id,
                                  dimension_x: 120,
                                  dimension_y: 80,
                                  dimension_z: 140,
                                  payload_in_kg: 200,
                                  quantity: 1)
      cargo_2 = FactoryBot.create(:legacy_cargo_item,
                                  shipment_id: shipment.id,
                                  dimension_x: 120,
                                  dimension_y: 80,
                                  dimension_z: 150,
                                  payload_in_kg: 400,
                                  quantity: 2)
      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'calculation': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, [cargo_1, cargo_2], 0, 'pre', user).cargo_item_object
      expect(cargo_object['stackable']['weight']).to eq(1056)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.comparative' do
      cargos = [
        FactoryBot.create(:legacy_cargo_item,
                          shipment_id: shipment.id,
                          dimension_x: 10,
                          dimension_y: 15,
                          dimension_z: 20,
                          payload_in_kg: 30.0 / 45.0,
                          quantity: 45),
        FactoryBot.create(:legacy_cargo_item,
                          shipment_id: shipment.id,
                          dimension_x: 30,
                          dimension_y: 30,
                          dimension_z: 25,
                          payload_in_kg: 36.0 / 15.0,
                          quantity: 15),
        FactoryBot.create(:legacy_cargo_item,
                          shipment_id: shipment.id,
                          dimension_x: 25,
                          dimension_y: 25,
                          dimension_z: 20,
                          payload_in_kg: 168.0 / 32.0,
                          quantity: 32)
      ]
      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'comparative': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking,
                                           cbm_ratio: 200,
                                           load_meterage: {
                                             ratio: 1000,
                                             area: 48_000
                                           },
                                           tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
      expect(cargo_object['stackable']['weight'].to_i).to eq(234)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.comparative (non-stackable)' do
      cargos = [
        FactoryBot.create(:legacy_cargo_item,
                          shipment_id: shipment.id,
                          dimension_x: 10,
                          dimension_y: 15,
                          dimension_z: 20,
                          payload_in_kg: 30.0 / 45.0,
                          stackable: false,
                          quantity: 45),
        FactoryBot.create(:legacy_cargo_item,
                          shipment_id: shipment.id,
                          dimension_x: 30,
                          dimension_y: 30,
                          dimension_z: 25,
                          payload_in_kg: 36.0 / 15.0,
                          stackable: false,
                          quantity: 15),
        FactoryBot.create(:legacy_cargo_item,
                          shipment_id: shipment.id,
                          dimension_x: 25,
                          dimension_y: 25,
                          dimension_z: 20,
                          payload_in_kg: 168.0 / 32.0,
                          stackable: false,
                          quantity: 32)
      ]
      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'comparative': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking,
                                           cbm_ratio: 200,
                                           load_meterage: {
                                             ratio: 1000,
                                             ldm_limit: 0.5
                                           },
                                           tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
      expect(cargo_object['non_stackable']['weight'].to_i).to eq(1677)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.calculation with agg cargo' do
      aggregated_cargo = FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id, volume: 1.5, weight: 3000)

      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'calculation': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, [aggregated_cargo], 0, 'pre', user).cargo_item_object
      expect(cargo_object['stackable']['weight']).to eq(3000)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only' do
      cargo_1 = FactoryBot.create(:legacy_cargo_item,
                                  shipment_id: shipment.id,
                                  dimension_x: 120,
                                  dimension_y: 80,
                                  dimension_z: 140,
                                  payload_in_kg: 200,
                                  quantity: 1)
      cargo_2 = FactoryBot.create(:legacy_cargo_item,
                                  shipment_id: shipment.id,
                                  dimension_x: 120,
                                  dimension_y: 80,
                                  dimension_z: 150,
                                  payload_in_kg: 400,
                                  quantity: 2)

      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'load_meterage_only': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, [cargo_1, cargo_2], 0, 'pre', user).cargo_item_object
      expect(cargo_object['stackable']['weight']).to eq(1136)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only (low limit)' do
      cargo_1 = FactoryBot.create(:legacy_cargo_item,
                                  shipment_id: shipment.id,
                                  dimension_x: 120,
                                  dimension_y: 80,
                                  dimension_z: 140,
                                  payload_in_kg: 200,
                                  quantity: 1)
      cargo_2 = FactoryBot.create(:legacy_cargo_item,
                                  shipment_id: shipment.id,
                                  dimension_x: 120,
                                  dimension_y: 80,
                                  dimension_z: 150,
                                  payload_in_kg: 400,
                                  quantity: 2)

      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'load_meterage_only': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 0.5, ratio: 1000 }, tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, [cargo_1, cargo_2], 0, 'pre', user).cargo_item_object
      expect(cargo_object['non_stackable']['weight']).to eq(0.12e4)
    end

    it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only agg cargo' do
      cargo = FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id)
      FactoryBot.create(:tenants_scope, target: tenants_user, content: { 'consolidation': { 'trucking': { 'load_meterage_only': true } } })
      trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 0.5, ratio: 1000 }, tenant: tenant)
      cargo_object = described_class.new(trucking_pricing, [cargo], 0, 'pre', user).cargo_item_object
      expect(cargo_object['non_stackable']['weight']).to eq(0.25e3)
    end
  end

  context 'value extractors' do
    describe '.trucking_payload_weight' do
      it 'correctly returns the combined payload weight of all items in item group' do
        payload_1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).trucking_payload_weight(default_cargos.first)
        payload_2 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).trucking_payload_weight(default_cargos.last)
        expect(payload_1).to eq(200)
        expect(payload_2).to eq(800)
      end
    end

    describe '.cargo_volume' do
      it 'correctly returns the combined volume of all items in item group' do
        volume_1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_volume(default_cargos.first)
        volume_2 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_volume(default_cargos.last)
        expect(volume_1).to eq(1.344)
        expect(volume_2).to eq(2.88)
      end
    end

    describe '.cargos_volume' do
      it 'correctly returns the combined volume of all items in item groups' do
        volume_1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargos_volume(default_cargos)
        expect(volume_1).to eq(4.224)
      end
    end

    describe '.cargo_quantity' do
      it 'correctly returns the quantity of an item' do
        quantity = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_quantity(default_cargos.last)
        expect(quantity).to eq(2)
      end
      it 'correctly returns the default quantity of1 for agg cargo' do
        quantity = described_class.new(default_trucking_pricing, [agg_cargo], 0, 'pre', user).cargo_quantity(agg_cargo)
        expect(quantity).to eq(1)
      end
    end

    describe '.cargo_data_value' do
      it 'correctly returns the dimension_x of an item' do
        dimension_x = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_data_value(:dimension_x, default_cargos.last)
        expect(dimension_x).to eq(120)
      end
      it 'correctly returns the dimension_x of an hash item' do
        dimension_x = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_data_value(:dimension_x, consolidated_cargo)
        expect(dimension_x).to eq(300)
      end
    end

    describe '.cargo_unit_volume' do
      it 'correctly returns the unit volume of all items in item group' do
        volume_1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_unit_volume(default_cargos.first)
        volume_2 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_unit_volume(default_cargos.last)
        expect(volume_1).to eq(1.344)
        expect(volume_2).to eq(1.44)
      end

      it 'correctly returns the unit volume of agg cargo' do
        agg_cargo = FactoryBot.create(:legacy_aggregated_cargo, volume: 1.5, weight: 1000)
        volume_1 = described_class.new(default_trucking_pricing, [agg_cargo], 0, 'pre', user).cargo_unit_volume(agg_cargo)
        expect(volume_1).to eq(1.5)
      end
    end

    describe '.trucking_cbm_weight' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 200)
        cbm_1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_cbm_weight(trucking_pricing, default_cargos.first)
        cbm_2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_cbm_weight(trucking_pricing, default_cargos.last)
        expect(cbm_1).to eq(268.8)
        expect(cbm_2).to eq(576)
      end

      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 200)
        agg_cargo = FactoryBot.create(:legacy_aggregated_cargo, volume: 1.5, weight: 1000)
        cbm = described_class.new(trucking_pricing, [agg_cargo], 0, 'pre', user).trucking_cbm_weight(trucking_pricing, agg_cargo)
        expect(cbm).to eq(300)
      end
    end

    describe '.trucking_chargeable_weight_by_stacked_area' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000 })
        tcw_1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_stacked_area(trucking_pricing, default_cargos.first)
        tcw_2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_stacked_area(trucking_pricing, default_cargos.last)
        expect(tcw_1).to eq(400)
        expect(tcw_2).to eq(800)
      end
    end

    describe '.trucking_chargeable_weight_by_height' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000 })
        tcw_1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_height(trucking_pricing, default_cargos.first)
        tcw_2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_height(trucking_pricing, default_cargos.last)
        expect(tcw_1).to eq(400)
        expect(tcw_2).to eq(800)
      end
    end

    describe '.trucking_chargeable_weight_by_area' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000 })
        tcw_1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_area(trucking_pricing, default_cargos.first)
        tcw_2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_area(trucking_pricing, default_cargos.last)
        expect(tcw_1).to eq(400)
        expect(tcw_2).to eq(800)
      end
    end

    describe '.calc_cargo_load_meterage_height' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000, height: 130 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).calc_cargo_load_meterage_height(trucking_pricing, cargo_object, default_cargos.first)

        expect(result_object.dig('non_stackable', 'weight')).to eq(618.24)
        expect(result_object.dig('non_stackable', 'volume')).to eq(1.344)
        expect(result_object.dig('non_stackable', 'number_of_items')).to eq(1)
      end
    end

    describe '.calc_cargo_load_meterage_area' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).calc_cargo_load_meterage_area(trucking_pricing, cargo_object, ldm_cargo)

        expect(result_object.dig('non_stackable', 'weight')).to eq(3091.2)
        expect(result_object.dig('non_stackable', 'volume')).to eq(33.6)
        expect(result_object.dig('non_stackable', 'number_of_items')).to eq(5)
      end
    end

    describe '.calc_aggregated_cargo_load_meterage_area' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).calc_aggregated_cargo_load_meterage(trucking_pricing, cargo_object, agg_cargo)

        expect(result_object.dig('non_stackable', 'weight')).to eq(1000)
        expect(result_object.dig('non_stackable', 'volume')).to eq(1.5)
        expect(result_object.dig('non_stackable', 'number_of_items')).to eq(1)
      end
    end
  end

  context 'calculation' do
    describe '.perform' do
      it 'raises an error with hard trucking limit' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg)
        FactoryBot.create(:tenants_scope, target: tenants_user, content: { hard_trucking_limit: true })

        expect { described_class.new(default_trucking_pricing, [outsized_cargo], 0, 'pre', user).perform }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
      end

      it 'raises an error with hard trucking limit (unit kg rates)' do
        FactoryBot.create(:tenants_scope, target: tenants_user, content: { hard_trucking_limit: true })
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg)

        expect { described_class.new(trucking_pricing, [outsized_cargo], 0, 'pre', user).perform }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
      end

      it 'uses the max value without hard_trucking_limit' do
        FactoryBot.create(:tenants_scope, target: tenants_user, content: { hard_trucking_limit: false })
        result_object = described_class.new(default_trucking_pricing, [outsized_cargo], 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'uses the area limit' do
        area_trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 1, ratio: 1000 }, tenant: tenant)
        FactoryBot.create(:tenants_scope, target: tenants_user, content: { hard_trucking_limit: false })
        result_object = described_class.new(area_trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
        expect(result_object.dig('stackable')).to eq({})
      end

      it 'calulates for agg cargo' do
        area_trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 1, ratio: 1000 }, tenant: tenant)
        FactoryBot.create(:tenants_scope, target: tenants_user, content: { continuous_rounding: true })
        result_object = described_class.new(area_trucking_pricing, [agg_cargo], 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'uses the max value without hard_trucking_limit (unit and kg)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg)
        FactoryBot.create(:tenants_scope, target: tenants_user, content: { hard_trucking_limit: false })
        result_object = described_class.new(trucking_pricing, [outsized_cargo], 0, 'pre', user).perform

        expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
        expect(result_object.dig('stackable')).to eq({})
      end

      it 'uses the max value with forced minimum' do
        trucking_pricing = FactoryBot.create(:trucking_with_forced_min)
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable', :value)).to eq(1_000_000)
        expect(result_object.dig('stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking' do
        trucking_pricing = FactoryBot.create(:fcl_20_trucking)
        result_object = described_class.new(trucking_pricing, [fcl_cargo], 0, 'pre', user).perform

        expect(result_object.dig("container_#{fcl_cargo.id}", :currency)).to eq('SEK')
      end

      it 'correctly returns the calculated trucking with fees' do
        trucking_pricing = FactoryBot.create(:trucking_with_fees)
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
        expect(result_object.dig('stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (cbm rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (cbm kg rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_kg_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (cbm kg rates) - out of range' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_kg_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, [outsized_cargo], 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (cbm kg rates) - below range' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_kg_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, [mini_cargo], 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (wm rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_wm_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (unit rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (unit and kg rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end

      it 'correctly returns the calculated trucking (unit and kg rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_per_km, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform

        expect(result_object.dig('stackable', :currency)).to eq('SEK')
        expect(result_object.dig('non_stackable')).to eq({})
      end
    end

    describe '.handle_range_fare' do
      let(:metadata_id) { SecureRandom.uuid }
      let(:metadata) do
        [
          {
            metadata_id: metadata_id,
            fees: {
              THC: {
                breakdowns: [
                  {
                    adjusted_rate: {
                      range: [
                        { 'max' => 100.0, 'min' => 10.0, 'rate' => 15.0 }
                      ]
                    }
                  }
                ]
              }
            }
          }
        ]
      end
      let(:trucking_pricing_with_meta) do
        default_trucking_pricing.as_json.merge(metadata_id: metadata_id)
      end

      let!(:klass) { described_class.new(trucking_pricing_with_meta, default_cargos, 0, 'pre', user, metadata) }

      context 'with CBM_TON_RANGE rate basis' do
        let(:fee) { FactoryBot.build(:per_unit_ton_cbm_range_trucking_fee) }

        it 'calculates in favour of CBM' do
          cargo_hash = {
            volume: 6,
            weight: 500,
            raw_weight: 500
          }.with_indifferent_access
          result = klass.handle_range_fare(fee: fee, cargo: cargo_hash)
          expect(result).to eq(57)
        end

        it 'calculates in favour of TON' do
          cargo_hash = {
            volume: 1,
            weight: 500,
            raw_weight: 500
          }.with_indifferent_access
          result = klass.handle_range_fare(fee: fee, cargo: cargo_hash)
          expect(result).to eq(57)
        end

        it 'returns the min when out of range' do
          cargo_hash = {
            volume: 100,
            weight: 500,
            raw_weight: 500
          }.with_indifferent_access
          result = klass.handle_range_fare(fee: fee, cargo: cargo_hash)
          expect(result).to eq(57)
        end
      end

      context 'with CBM_RANGE rate basis' do
        let(:fee) { FactoryBot.build(:per_cbm_range_trucking_fee) }

        it 'returns the correct fee_range for the larger volume' do
          cargo_hash = { volume: 11, raw_weight: 11_000, weight: 11_000, quantity: 9 }.with_indifferent_access
          value = klass.handle_range_fare(fee: fee, cargo: cargo_hash)
          expect(value).to eq(110)
        end

        it 'returns the correct fee_range for the smaller volume' do
          cargo_hash = { volume: 4, raw_weight: 4000, weight: 4000, quantity: 9 }.with_indifferent_access
          value = klass.handle_range_fare(fee: fee, cargo: cargo_hash)
          expect(value).to eq(20)
        end
      end
    end
  end
end
