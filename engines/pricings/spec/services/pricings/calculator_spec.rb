# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Pricings::Calculator do
  let(:load_type) { 'cargo_item' }
  let(:direction) { 'export' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }

  let(:vehicle) do
    FactoryBot.create(:vehicle,
                      tenant_vehicles: [tenant_vehicle_1])
  end
  let(:tenant_vehicle_1) { FactoryBot.create(:legacy_tenant_vehicle, name: 'slowly', tenant: tenant) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:legacy_user, tenant: tenant, currency: currency.base) }
  let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_20_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:fcl_40_hq_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:agg_shipment) { FactoryBot.create(:legacy_shipment, tenant: tenant, user: user) }
  let(:lcl_pricing) { FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:lcl_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id) }
  let(:fcl_20_pricing) { FactoryBot.create(:fcl_20_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:fcl_20_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_pricing) { FactoryBot.create(:fcl_40_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:fcl_40_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40', shipment_id: fcl_20_shipment.id) }
  let(:fcl_40_hq_pricing) { FactoryBot.create(:fcl_40_hq_pricing, tenant_vehicle: tenant_vehicle_1) }
  let(:fcl_40_hq_cargo) { FactoryBot.create(:legacy_container, cargo_class: 'fcl_40_hq', shipment_id: fcl_40_hq_shipment.id) }
  let(:overweight_cargo) { FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id, payload_in_kg: 3000) }
  let(:agg_cargo) { FactoryBot.create(:legacy_aggregated_cargo, shipment_id: agg_shipment.id) }
  let(:consolidated_cargo) do
    {
      id: 'ids',
      dimension_x: 240,
      dimension_y: 160,
      dimension_z: 240,
      volume: 3.748,
      payload_in_kg: 600,
      cargo_class: 'lcl',
      chargeable_weight: 3748,
      num_of_items: 2,
      quantity: 1
    }
  end

  describe '.get_cargo_hash' do
    it 'returns the correct cargo weight for a cargo item' do
      hash = described_class.new(cargo: lcl_cargo,
                                 pricing: lcl_pricing.as_json,
                                 user: user,
                                 mode_of_transport: 'ocean',
                                 date: Time.zone.today + 10.days).get_cargo_hash
      expect(hash[:weight]).to eq(200)
    end
    it 'returns the correct cargo weight for an agg cargo item' do
      hash = described_class.new(cargo: agg_cargo,
                                 pricing: lcl_pricing.as_json,
                                 user: user,
                                 mode_of_transport: 'ocean',
                                 date: Time.zone.today + 10.days).get_cargo_hash
      expect(hash[:weight]).to eq(200)
    end
    it 'returns the correct cargo weight for a container' do
      hash = described_class.new(cargo: fcl_20_cargo,
                                 pricing: lcl_pricing.as_json,
                                 user: user,
                                 mode_of_transport: 'ocean',
                                 date: Time.zone.today + 10.days).get_cargo_hash
      expect(hash[:weight]).to eq(10_000)
    end
    it 'returns the correct cargo weight for a consolidated cargo' do
      hash = described_class.new(cargo: consolidated_cargo,
                                 pricing: lcl_pricing.as_json,
                                 user: user,
                                 mode_of_transport: 'ocean',
                                 date: Time.zone.today + 10.days).get_cargo_hash
      expect(hash[:weight]).to eq(3748)
    end
  end

  describe '.round_fee' do
    it 'rounds when should_round is true' do
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: lcl_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).round_fee(123.44578, true)
      expect(result).to eq(123.45)
    end
    it 'doesn`t round when should_round is false' do
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: lcl_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).round_fee(123.44578, false)
      expect(result).to eq(123.44578)
    end
  end

  describe '.determine_cargo_item_price' do
    it 'calculates the correct price for PER_WM' do
      wm_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_wm, pricing: wm_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: wm_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 222.2, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_hbl' do
      hbl_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_hbl, pricing: hbl_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: hbl_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 1111, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_shipment' do
      shipment_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_shipment, pricing: shipment_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: shipment_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 1111, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_item' do
      item_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_item, pricing: item_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: item_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 1111, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_cbm' do
      cbm_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_cbm, pricing: cbm_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: cbm_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 8.888, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_kg' do
      kg_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_kg, pricing: kg_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: kg_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 222_200, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_ton' do
      ton_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_ton, pricing: ton_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: ton_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 222.2, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_x_kg_flat' do
      x_kg_flat_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_x_kg_flat, pricing: x_kg_flat_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: x_kg_flat_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 5000, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_cbm_range' do
      cbm_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_cbm_range, pricing: cbm_range_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: cbm_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 0.064, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_cbm_range above range' do
      overcbm_cargo = FactoryBot.create(:legacy_aggregated_cargo, shipment_id: agg_shipment.id, weight: 1000, volume: 13)
      cbm_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_cbm_range, pricing: cbm_range_pricing)
      result = described_class.new(cargo: overcbm_cargo,
                                   pricing: cbm_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 156, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_container_range' do
      container_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_container_range, pricing: container_range_pricing)
      result = described_class.new(cargo: fcl_20_cargo,
                                   pricing: container_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform

      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 60, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_container_range above range' do
      fat_fcl_20_cargo = FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: fcl_20_shipment.id, payload_in_kg: 24_000)
      container_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_container_range, pricing: container_range_pricing)
      result = described_class.new(cargo: fat_fcl_20_cargo,
                                   pricing: container_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 60, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_unit_range' do
      unit_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_unit_range, pricing: unit_range_pricing)
      result = described_class.new(cargo: fcl_20_cargo,
                                   pricing: unit_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 60, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_unit_range above range' do
      FactoryBot.create(:legacy_container, cargo_class: 'fcl_20', shipment_id: fcl_20_shipment.id, payload_in_kg: 24_000)
      unit_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_unit_range, pricing: unit_range_pricing)
      result = described_class.new(cargo: fcl_20_cargo,
                                   pricing: unit_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 60, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_unit_ton_cbm_range (CBM)' do
      unit_ton_cbm_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      cbm_lcl_cargo = FactoryBot.create(:legacy_cargo_item,
                                        shipment_id: lcl_shipment.id,
                                        cargo_item_type_id: pallet.id,
                                        payload_in_kg: 1000,
                                        dimension_x: 100,
                                        dimension_y: 100,
                                        dimension_z: 100)
      FactoryBot.create(:fee_per_unit_ton_cbm_range, pricing: unit_ton_cbm_range_pricing)
      result = described_class.new(cargo: cbm_lcl_cargo,
                                   pricing: unit_ton_cbm_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 100, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_unit_ton_cbm_range (CBM) out of range' do
      overcbm_cargo = FactoryBot.create(:legacy_aggregated_cargo, shipment_id: agg_shipment.id, weight: 10, volume: 13)
      unit_ton_cbm_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)

      FactoryBot.create(:fee_per_unit_ton_cbm_range, pricing: unit_ton_cbm_range_pricing)
      result = described_class.new(cargo: overcbm_cargo,
                                   pricing: unit_ton_cbm_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 1, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_unit_ton_cbm_range (TON)' do
      unit_ton_cbm_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      ton_lcl_cargo = FactoryBot.create(:legacy_cargo_item,
                                        shipment_id: lcl_shipment.id,
                                        cargo_item_type_id: pallet.id,
                                        payload_in_kg: 5000,
                                        dimension_x: 300,
                                        dimension_y: 300,
                                        dimension_z: 300)
      FactoryBot.create(:fee_per_unit_ton_cbm_range, pricing: unit_ton_cbm_range_pricing)
      result = described_class.new(cargo: ton_lcl_cargo,
                                   pricing: unit_ton_cbm_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 400, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_kg_range' do
      kg_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_kg_range, pricing: kg_range_pricing)
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: kg_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 1600, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_kg_range when out of range' do
      kg_range_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_kg_range, pricing: kg_range_pricing)
      result = described_class.new(cargo: overweight_cargo,
                                   pricing: kg_range_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 18_000, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_cbm_kg_heavy' do
      cbm_kg_heavy_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_cbm_kg_heavy, pricing: cbm_kg_heavy_pricing)
      result = described_class.new(cargo: overweight_cargo,
                                   pricing: cbm_kg_heavy_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 12, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_item_heavy' do
      item_heavy_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_item_heavy, pricing: item_heavy_pricing)
      fat_cargo = FactoryBot.create(:legacy_cargo_item, shipment_id: lcl_shipment.id, cargo_item_type_id: pallet.id, payload_in_kg: 2200)

      result = described_class.new(cargo: fat_cargo,
                                   pricing: item_heavy_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 250, 'currency' => 'EUR')
    end

    it 'calculates the correct price for per_item_heavy beyond range' do
      item_heavy_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_item_heavy, pricing: item_heavy_pricing)
      result = described_class.new(cargo: overweight_cargo,
                                   pricing: item_heavy_pricing.as_json,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Time.zone.today + 10.days).perform
      expect(result.dig('total').slice('value', 'currency')).to eq('value' => 250, 'currency' => 'EUR')
    end
  end

  describe '.determine_cargo_item_price with flat_margins' do
    it 'it calculates the correct price for PER_WM and 100' do
      wm_pricing = FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle_1, tenant: tenant)
      FactoryBot.create(:fee_per_wm, pricing: wm_pricing)
      pricing_with_margins = wm_pricing.as_json.merge('flat_margins' => { 'bas' => 100 })
      result = described_class.new(cargo: lcl_cargo,
                                   pricing: pricing_with_margins,
                                   user: user,
                                   mode_of_transport: 'ocean',
                                   date: Date.today + 10.days).perform
      expect(result.dig('total', 'value')).to eq(322.2)
      expect(result.dig('total', 'currency')).to eq('EUR')
    end
  end
end
