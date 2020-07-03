# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OfferCalculator::TruckingTools do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let!(:default_max_dimension) { FactoryBot.create(:legacy_max_dimensions_bundle, organization: organization) }
  let!(:default_aggr_max_dimension) { FactoryBot.create(:aggregated_max_dimensions_bundle, organization: organization) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:trip) { FactoryBot.create(:legacy_trip) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let(:destination_nexus) { FactoryBot.create(:legacy_nexus, hubs: [destination_hub]) }
  let!(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization, stops: [origin_stop, destination_stop], layovers: [origin_layover, destination_layover], trips: [trip]) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: load_type, direction: direction, user: user, organization: organization, origin_nexus: origin_nexus, destination_nexus: destination_nexus, trip: itinerary.trips.first, itinerary: itinerary) }
  let(:origin_nexus) { FactoryBot.create(:legacy_nexus, hubs: [origin_hub]) }
  let(:origin_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:destination_hub) { FactoryBot.create(:legacy_hub, organization: organization) }
  let(:origin_stop) { FactoryBot.create(:legacy_stop, index: 0, hub_id: origin_hub.id, layovers: [origin_layover]) }
  let(:destination_stop) { FactoryBot.create(:legacy_stop, index: 1, hub_id: destination_hub.id, layovers: [destination_layover]) }
  let(:origin_layover) { FactoryBot.create(:legacy_layover, stop_index: 0, trip: trip) }
  let(:destination_layover) { FactoryBot.create(:legacy_layover, stop_index: 1, trip: trip) }
  let(:default_trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, organization: organization) }
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
                        width: 120,
                        length: 80,
                        height: 140,
                        payload_in_kg: 200,
                        quantity: 1),
      FactoryBot.create(:legacy_cargo_item,
                        shipment_id: shipment.id,
                        width: 120,
                        length: 80,
                        height: 150,
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
                      width: 120,
                      length: 80,
                      height: 140,
                      payload_in_kg: 200,
                      quantity: 5)
  end
  let!(:outsized_cargo) do
    FactoryBot.create(:legacy_cargo_item,
                      shipment_id: shipment.id,
                      width: 240,
                      length: 160,
                      height: 230,
                      payload_in_kg: 1000,
                      quantity: 10)
  end
  let!(:mini_cargo) do
    FactoryBot.create(:legacy_cargo_item,
                      shipment_id: shipment.id,
                      width: 1,
                      length: 1,
                      height: 1,
                      payload_in_kg: 1,
                      quantity: 1)
  end
  let(:agg_cargo) { FactoryBot.create(:legacy_aggregated_cargo, volume: 1.5, weight: 1000, shipment: shipment) }

  let!(:consolidated_cargo) do
    {
      id: 'ids',
      width: 300,
      length: 240,
      height: 300,
      volume: 21.6,
      payload_in_kg: 4000,
      cargo_class: 'lcl',
      num_of_items: 3,
      quantity: 1
    }
  end

  before do
    Organizations.current_id = organization.id
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
    context 'with scope consolidation.trucking.calculation' do
      let(:cargos) do
        [
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 120,
                            length: 80,
                            height: 140,
                            payload_in_kg: 200,
                            quantity: 1),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 120,
                            length: 80,
                            height: 150,
                            payload_in_kg: 400,
                            quantity: 2)
        ]
      end
      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, organization: organization) }

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'calculation': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.calculation' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['stackable']['weight']).to eq(1056)
      end
    end

    context 'with  scope consolidation.trucking.comparative' do
      let(:cargos) do
        [
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 10,
                            length: 15,
                            height: 20,
                            payload_in_kg: 30.0 / 45.0,
                            quantity: 45),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 30,
                            length: 30,
                            height: 25,
                            payload_in_kg: 36.0 / 15.0,
                            quantity: 15),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 25,
                            length: 25,
                            height: 20,
                            payload_in_kg: 168.0 / 32.0,
                            quantity: 32)
        ]
      end
      let(:trucking_pricing) do
        FactoryBot.create(:trucking_trucking,
                          cbm_ratio: 200,
                          load_meterage: {
                            ratio: 1000,
                            area: 48_000
                          },
                          organization: organization)
      end

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'comparative': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.comparative' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['stackable']['weight'].to_i).to eq(234)
      end
    end

    context 'with scope consolidation.trucking.comparative (non-stackable)' do
      let(:cargos) do
        [
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 10,
                            length: 15,
                            height: 20,
                            payload_in_kg: 30.0 / 45.0,
                            stackable: false,
                            quantity: 45),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 30,
                            length: 30,
                            height: 25,
                            payload_in_kg: 36.0 / 15.0,
                            stackable: false,
                            quantity: 15),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 25,
                            length: 25,
                            height: 20,
                            payload_in_kg: 168.0 / 32.0,
                            stackable: false,
                            quantity: 32)
        ]
      end
      let(:trucking_pricing) do
        FactoryBot.create(:trucking_trucking,
                          cbm_ratio: 200,
                          load_meterage: {
                            ratio: 1000,
                            ldm_limit: 0.5
                          },
                          organization: organization)
      end

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'comparative': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.comparative (non-stackable)' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['non_stackable']['weight'].to_i).to eq(1677)
      end
    end

    context 'with scope consolidation.trucking.calculation with agg cargo' do
      let(:cargos) do
        [FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id, volume: 1.5, weight: 3000)]
      end
      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, organization: organization) }

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'calculation': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.calculation with agg cargo' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['stackable']['weight']).to eq(3000)
      end
    end

    context 'with scope consolidation.trucking.load_meterage_only' do
      let(:cargos) do
        [
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 120,
                            length: 80,
                            height: 140,
                            payload_in_kg: 200,
                            quantity: 1),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 120,
                            length: 80,
                            height: 150,
                            payload_in_kg: 400,
                            quantity: 2)
        ]
      end
      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: {}, organization: organization) }

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'load_meterage_only': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['stackable']['weight']).to eq(1136)
      end
    end

    context 'with consolidation.trucking.load_meterage_only (low limit)' do
      let(:cargos) do
        [
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 120,
                            length: 80,
                            height: 140,
                            payload_in_kg: 200,
                            quantity: 1),
          FactoryBot.create(:legacy_cargo_item,
                            shipment_id: shipment.id,
                            width: 120,
                            length: 80,
                            height: 150,
                            payload_in_kg: 400,
                            quantity: 2)
        ]
      end
      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 0.5, ratio: 1000 }, organization: organization) }

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'load_meterage_only': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only (low limit)' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['non_stackable']['weight']).to eq(0.12e4)
      end
    end

    context 'with scope consolidation.trucking.load_meterage_only agg cargo' do
      let(:cargos) do
        [
          FactoryBot.create(:legacy_aggregated_cargo, shipment_id: shipment.id)
        ]
      end
      let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 0.5, ratio: 1000 }, organization: organization) }

      before do
        FactoryBot.create(:organizations_scope, target: user, content: { 'consolidation': { 'trucking': { 'load_meterage_only': true } } })
      end

      it 'correctly consolidates the cargo values for scope consolidation.trucking.load_meterage_only agg cargo' do
        cargo_object = described_class.new(trucking_pricing, cargos, 0, 'pre', user).cargo_item_object
        expect(cargo_object['non_stackable']['weight']).to eq(0.25e3)
      end
    end
  end

  context 'when extracting values' do
    describe '.trucking_payload_weight' do
      it 'correctly returns the combined payload weight of all items in item group' do
        payload1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).trucking_payload_weight(default_cargos.first)
        payload2 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).trucking_payload_weight(default_cargos.last)
        aggregate_failures do
          expect(payload1).to eq(200)
          expect(payload2).to eq(800)
        end
      end
    end

    describe '.cargo_volume' do
      it 'correctly returns the combined volume of all items in item group' do
        volume1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_volume(default_cargos.first)
        volume2 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_volume(default_cargos.last)
        aggregate_failures do
          expect(volume1).to eq(1.344)
          expect(volume2).to eq(2.88)
        end
      end
    end

    describe '.cargos_volume' do
      it 'correctly returns the combined volume of all items in item groups' do
        volume1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargos_volume(default_cargos)
        expect(volume1).to eq(4.224)
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
      let(:target_cargo) { default_cargos.last }
      let(:service) { described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user) }

      it 'correctly returns the width of an item' do
        width = service.cargo_data_value(:width, target_cargo)
        expect(width).to eq(target_cargo.width)
      end

      it 'correctly returns the width of an hash item' do
        width = service.cargo_data_value(:width, consolidated_cargo)
        expect(width).to eq(consolidated_cargo[:width])
      end

      it 'correctly returns the length of an item' do
        length = service.cargo_data_value(:length, target_cargo)
        expect(length).to eq(target_cargo.length)
      end

      it 'correctly returns the length of an hash item' do
        length = service.cargo_data_value(:length, consolidated_cargo)
        expect(length).to eq(consolidated_cargo[:length])
      end
    end

    describe '.cargo_unit_volume' do
      it 'correctly returns the unit volume of all items in item group' do
        volume1 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_unit_volume(default_cargos.first)
        volume2 = described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user).cargo_unit_volume(default_cargos.last)
        aggregate_failures do
          expect(volume1).to eq(1.344)
          expect(volume2).to eq(1.44)
        end
      end

      it 'correctly returns the unit volume of agg cargo' do
        agg_cargo = FactoryBot.create(:legacy_aggregated_cargo, volume: 1.5, weight: 1000)
        volume1 = described_class.new(default_trucking_pricing, [agg_cargo], 0, 'pre', user).cargo_unit_volume(agg_cargo)
        expect(volume1).to eq(1.5)
      end
    end

    describe '.trucking_cbm_weight' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 200)
        cbm1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_cbm_weight(trucking_pricing, default_cargos.first)
        cbm2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_cbm_weight(trucking_pricing, default_cargos.last)
        aggregate_failures do
          expect(cbm1).to eq(268.8)
          expect(cbm2).to eq(576)
        end
      end

      it 'correctly returns the combined cbm weight of all items in item group ( agg cargo)' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 200)
        agg_cargo = FactoryBot.create(:legacy_aggregated_cargo, volume: 1.5, weight: 1000)
        cbm = described_class.new(trucking_pricing, [agg_cargo], 0, 'pre', user).trucking_cbm_weight(trucking_pricing, agg_cargo)
        expect(cbm).to eq(300)
      end
    end

    describe '.trucking_chargeable_weight_by_stacked_area' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000 })
        tcw1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_stacked_area(trucking_pricing, default_cargos.first)
        tcw2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_stacked_area(trucking_pricing, default_cargos.last)
        aggregate_failures do
          expect(tcw1).to eq(400)
          expect(tcw2).to eq(800)
        end
      end
    end

    describe '.trucking_chargeable_weight_by_height' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000 })
        tcw1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_height(trucking_pricing, default_cargos.first)
        tcw2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_height(trucking_pricing, default_cargos.last)
        aggregate_failures do
          expect(tcw1).to eq(400)
          expect(tcw2).to eq(800)
        end
      end
    end

    describe '.trucking_chargeable_weight_by_area' do
      it 'correctly returns the combined cbm weight of all items in item group' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000 })
        tcw1 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_area(trucking_pricing, default_cargos.first)
        tcw2 = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).trucking_chargeable_weight_by_area(trucking_pricing, default_cargos.last)
        aggregate_failures do
          expect(tcw1).to eq(400)
          expect(tcw2).to eq(800)
        end
      end
    end

    describe '.calc_cargo_load_meterage_height' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000, height: 130 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).calc_cargo_load_meterage_height(trucking_pricing, cargo_object, default_cargos.first)
        aggregate_failures do
          expect(result_object.dig('non_stackable', 'weight')).to eq(618.24)
          expect(result_object.dig('non_stackable', 'volume')).to eq(1.344)
          expect(result_object.dig('non_stackable', 'number_of_items')).to eq(1)
        end
      end
    end

    describe '.calc_cargo_load_meterage_area' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).calc_cargo_load_meterage_area(trucking_pricing, cargo_object, ldm_cargo)
        aggregate_failures do
          expect(result_object.dig('non_stackable', 'weight')).to eq(3091.2)
          expect(result_object.dig('non_stackable', 'volume')).to eq(33.6)
          expect(result_object.dig('non_stackable', 'number_of_items')).to eq(5)
        end
      end
    end

    describe '.calc_aggregated_cargo_load_meterage_area' do
      it 'correctly returns the loadmeterage values' do
        trucking_pricing = FactoryBot.create(:trucking_trucking, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).calc_aggregated_cargo_load_meterage(trucking_pricing, cargo_object, agg_cargo)
        aggregate_failures do
          expect(result_object.dig('non_stackable', 'weight')).to eq(1000)
          expect(result_object.dig('non_stackable', 'volume')).to eq(1.5)
          expect(result_object.dig('non_stackable', 'number_of_items')).to eq(1)
        end
      end
    end
  end

  context 'when calculating' do
    describe '.perform' do
      it 'raises an error with hard trucking limit' do
        FactoryBot.create(:organizations_scope, target: user, content: { hard_trucking_limit: true })

        expect { described_class.new(default_trucking_pricing, [outsized_cargo], 0, 'pre', user).perform }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
      end

      it 'raises an error with hard trucking limit (unit kg rates)' do
        FactoryBot.create(:organizations_scope, target: user, content: { hard_trucking_limit: true })
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg)

        expect { described_class.new(trucking_pricing, [outsized_cargo], 0, 'pre', user).perform }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
      end

      it 'uses the max value without hard_trucking_limit' do
        FactoryBot.create(:organizations_scope, target: user, content: { hard_trucking_limit: false })
        result_object = described_class.new(default_trucking_pricing, [outsized_cargo], 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'uses the area limit' do
        area_trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 1, ratio: 1000 }, organization: organization)
        FactoryBot.create(:organizations_scope, target: user, content: { hard_trucking_limit: false })
        result_object = described_class.new(area_trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
          expect(result_object.dig('stackable')).to eq({})
        end
      end

      it 'calulates for agg cargo' do
        area_trucking_pricing = FactoryBot.create(:trucking_trucking, cbm_ratio: 250, load_meterage: { area_limit: 1, ratio: 1000 }, organization: organization)
        FactoryBot.create(:organizations_scope, target: user, content: { continuous_rounding: true })
        result_object = described_class.new(area_trucking_pricing, [agg_cargo], 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'uses the max value without hard_trucking_limit (unit and kg)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg)
        FactoryBot.create(:organizations_scope, target: user, content: { hard_trucking_limit: false })
        result_object = described_class.new(trucking_pricing, [outsized_cargo], 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
          expect(result_object.dig('stackable')).to eq({})
        end
      end

      it 'uses the max value with forced minimum' do
        trucking_pricing = FactoryBot.create(:trucking_with_forced_min)
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable', :value)).to eq(1_000_000)
          expect(result_object.dig('stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking' do
        trucking_pricing = FactoryBot.create(:fcl_20_trucking)
        result_object = described_class.new(trucking_pricing, [fcl_cargo], 0, 'pre', user).perform

        expect(result_object.dig("container_#{fcl_cargo.id}", :currency)).to eq('SEK')
      end

      it 'correctly returns the calculated trucking with fees' do
        trucking_pricing = FactoryBot.create(:trucking_with_fees)
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('non_stackable', :currency)).to eq('SEK')
          expect(result_object.dig('stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (cbm rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (cbm kg rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_kg_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (cbm kg rates) - out of range' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_kg_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, [outsized_cargo], 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (cbm kg rates) - below range' do
        trucking_pricing = FactoryBot.create(:trucking_with_cbm_kg_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, [mini_cargo], 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (wm rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_wm_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (unit rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_rates, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (unit and kg rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_and_kg, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end

      it 'correctly returns the calculated trucking (unit per km rates)' do
        trucking_pricing = FactoryBot.create(:trucking_with_unit_per_km, load_meterage: { ratio: 1000, area: 48_000 })
        result_object = described_class.new(trucking_pricing, default_cargos, 0, 'pre', user).perform
        aggregate_failures do
          expect(result_object.dig('stackable', :currency)).to eq('SEK')
          expect(result_object.dig('non_stackable')).to eq({})
        end
      end
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
    let(:cbm_ton_fee) { FactoryBot.build(:per_unit_ton_cbm_range_trucking_fee) }
    let(:cbm_fee) { FactoryBot.build(:per_cbm_range_trucking_fee) }

    context 'when CBM_TON_RANGE fee calculates in favour of cbm' do
      let(:cargo_hash) do
        {
          volume: 6,
          weight: 500,
          raw_weight: 500
        }.with_indifferent_access
      end

      it 'calculates CBM_TON_RANGE in favour of CBM' do
        result = klass.handle_range_fare(fee: cbm_ton_fee, cargo: cargo_hash)
        expect(result).to eq(48)
      end
    end

    context 'when CBM_TON_RANGE fee calculates in favour of ton' do
      let(:cargo_hash) do
        {
          volume: 1,
          weight: 500,
          raw_weight: 500
        }.with_indifferent_access
      end

      it 'calculates CBM_TON_RANGE in favour of TON' do
        result = klass.handle_range_fare(fee: cbm_ton_fee, cargo: cargo_hash)
        expect(result).to eq(20.5)
      end
    end

    context 'when CBM_TON_RANGE fee retruns the min value' do
      let(:cargo_hash) do
        {
          volume: 100,
          weight: 500,
          raw_weight: 500
        }.with_indifferent_access
      end

      it 'returns the min for CBM_TON_RANGE when result is below min' do
        result = klass.handle_range_fare(fee: cbm_ton_fee, cargo: cargo_hash)
        expect(result).to eq(cbm_ton_fee['min'])
      end
    end

    context 'when CBM_RANGE fee calculates large volumes' do
      let(:cargo_hash) do
        {
          volume: 11, raw_weight: 11_000, weight: 11_000, quantity: 9
        }.with_indifferent_access
      end

      it 'returns the correct CBM_RANGE for the larger volume' do
        value = klass.handle_range_fare(fee: cbm_fee, cargo: cargo_hash)
        expect(value).to eq(110)
      end
    end

    context 'when CBM_RANGE fee calculates smaller volumes' do
      let(:cargo_hash) do
        {
          volume: 4, raw_weight: 4000, weight: 4000, quantity: 9
        }.with_indifferent_access
      end

      it 'returns the correct CBM_RANGE for the smaller volume' do
        value = klass.handle_range_fare(fee: cbm_fee, cargo: cargo_hash)
        expect(value).to eq(20)
      end
    end
  end

  describe '.trucking_range_finder' do
    let(:klass) { described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user, []) }

    it 'includes the upper value' do
      expect(klass.trucking_rate_range_finder(min: 0, max: 50, value: 50)).to be_truthy
    end

    it 'excludes the lower value' do
      expect(klass.trucking_rate_range_finder(min: 50, max: 150, value: 50)).to be_falsy
    end
  end

  describe '.sort_ranges' do
    let(:klass) { described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user, []) }
    let(:correct_ranges) do
      {
        'kg' => [
          { 'rate' => { 'base' => 100.0, 'value' => 237.5, 'currency' => 'SEK', 'rate_basis' => 'PER_X_KG' }, 'max_kg' => '200.0', 'min_kg' => '100.0', 'min_value' => 400.0 },
          { 'rate' => { 'base' => 100.0, 'value' => 237.5, 'currency' => 'SEK', 'rate_basis' => 'PER_X_KG' }, 'max_kg' => '300.0', 'min_kg' => '200.0', 'min_value' => 400.0 }
        ]
      }
    end
    let(:ranges) do
      {
        'kg' => [
          { 'rate' => { 'base' => 100.0, 'value' => 237.5, 'currency' => 'SEK', 'rate_basis' => 'PER_X_KG' }, 'max_kg' => '300.0', 'min_kg' => '200.0', 'min_value' => 400.0 },
          { 'rate' => { 'base' => 100.0, 'value' => 237.5, 'currency' => 'SEK', 'rate_basis' => 'PER_X_KG' }, 'max_kg' => '200.0', 'min_kg' => '100.0', 'min_value' => 400.0 }
        ]
      }
    end

    it 'sorts the range properly' do
      expect(klass.sort_ranges(ranges: ranges)).to eq(correct_ranges)
    end
  end

  describe '.hard_limit_checker' do
    let(:klass) { described_class.new(default_trucking_pricing, default_cargos, 0, 'pre', user, []) }
    let(:ranges) { default_trucking_pricing.rates['kg'] }

    it 'raises and error when out of range' do
      expect { klass.hard_limit_checker(rates: ranges, key: 'max_kg', limit: true, value: 6000) }.to raise_error(OfferCalculator::TruckingTools::LoadMeterageExceeded)
    end

    it 'returns true when above range and no limit is set' do
      expect(klass.hard_limit_checker(rates: ranges, key: 'max_kg', limit: false, value: 6000)).to be_truthy
    end

    it 'returns false when within the rate range' do
      expect(klass.hard_limit_checker(rates: ranges, key: 'max_kg', limit: false, value: 3000)).to be_falsy
    end
  end
end
