# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator do
  context 'acceptance' do
    let(:cargo_item_1) do
      {
        id: 1,
        quantity: 2,
        payload: '1_130.0',
        dimensions: {
          x: '100.0',
          y: '100.0',
          z: '100.0'
        },
        goods_value: '1_200.00'
      }
    end

    let(:rates_japan_freight) do
      # Source
      # Japan_SEARATES_USD
      # https://docs.google.com/spreadsheets/d/1XGoGGpzxp76lp8J89TxOxyL6k_G5sa0JzbYXPqR12Yo/edit#gid=823988371

      [
        {
          min_price: '19.0',
          currency: 'USD',
          category: 'BAS',
          kind: 'cargo_unit',
          prices: [
            {
              rule: nil,
              amount: '19.0',
              basis: 'weight_measure'
            }
          ]
        }
      ]
    end

    let(:rates_japan_local_charges) do
      # Source
      # Japan_local_USD
      # https://docs.google.com/spreadsheets/d/11lbOSY9UoyLNBr1QUGaCKTIISr8ajKjoCnkumUdavjE/edit#gid=1839599297

      # Fee Codes: THC, LCL, ANT, BL, AFR, ISP, VGM, CUST

      [
        {
          min_price: '5.0',
          currency: 'USD',
          category: 'ANT',
          kind: 'shipment',
          prices: [
            {
              rule: nil,
              amount: '5.0',
              basis: 'flat'
            }
          ]
        },
        {
          min_price: '2.5',
          currency: 'USD',
          category: 'BL',
          kind: 'shipment',
          prices: [
            {
              rule: nil,
              amount: '2.5',
              basis: 'bill_of_lading'
            }
          ]
        },
        {
          min_price: '35.0',
          currency: 'USD',
          category: 'AFR',
          kind: 'shipment',
          prices: [
            {
              rule: nil,
              amount: '35.0',
              basis: 'flat'
            }
          ]
        },
        {
          min_price: '18.0',
          currency: 'USD',
          category: 'VGM',
          kind: 'shipment',
          prices: [
            {
              rule: nil,
              amount: '18.0',
              basis: 'bill_of_lading'
            }
          ]
        },
        {
          min_price: '47.0',
          currency: 'USD',
          category: 'THC',
          kind: 'cargo_unit',
          reducer: 'sum',
          prices: [
            {
              rule: nil,
              amount: '47.0',
              basis: 'payload_unit_ton'
            },
            {
              rule: { eq: { field: 'telegraphic_transfer', arg_value: true } },
              amount: '44.0',
              basis: 'flat'
            }
          ]
        },
        {
          min_price: '42.0',
          currency: 'USD',
          category: 'LCL',
          kind: 'cargo_unit',
          prices: [
            {
              rule: nil,
              amount: '42.0',
              basis: 'payload_unit_ton'
            }
          ]
        },
        {
          min_price: '5.5',
          currency: 'USD',
          category: 'ISP',
          kind: 'cargo_unit',
          prices: [
            {
              rule: nil,
              amount: '5.5',
              basis: 'volume'
            }
          ]
        },
        {
          min_price: '25.0',
          currency: 'USD',
          category: 'CUST',
          kind: 'cargo_unit',
          prices: [
            {
              rule: { gt: { field: 'goods_value', arg_value: 1000 } },
              amount: '25.0',
              basis: 'flat'
            }
          ]
        }
      ]
    end

    let(:pricings) do
      [
        {
          conversion_ratios: {
            weight_measure: '1000.0'
          },
          route: 'Tokyo - Hamburg',
          rates: rates_japan_freight
        },
        {
          conversion_ratios: {
            weight_measure: '1000.0'
          },
          route: 'Tokyo - Hamburg',
          direction: 'Export',
          rates: rates_japan_local_charges
        }
      ]
    end

    let(:shipment_params) do
      {
        load_type: 'cargo_item',
        cargo_units: [cargo_item_1]
      }
    end

    context 'calculate' do
      let(:result) { described_class.calculate(shipment_params: shipment_params, pricings: pricings) }

      it 'calculates the correct price' do
        expect(result).to be_a ChargeCalculator::Models::Price

        node_tree = result.to_h
        expect(node_tree.to_json).to match_json_schema('main/price')

        cargo_item_1_volume  = BigDecimal('100.0')**3 / 1_000_000
        wm_conversion_ratio  = BigDecimal('1000')

        cargo_item_1_payload = BigDecimal(cargo_item_1[:payload])

        # Freight
        expect(node_tree.dig(:children, 0, :children, 0, :children, 0, :amount)).to eq(
          # BigDecimal("19.0") * [cargo_item_1_volume, cargo_item_1_payload / wm_conversion_ratio].max * 2
          42.94
        )

        # Local Charges
        expect(node_tree.dig(:children, 1, :children, 0, :amount)).to eq(
          5
        )
        expect(node_tree.dig(:children, 1, :children, 1, :amount)).to eq(
          # amount * number of bills of lading
          2.5
        )
        expect(node_tree.dig(:children, 1, :children, 2, :amount)).to eq(
          35
        )
        expect(node_tree.dig(:children, 1, :children, 3, :amount)).to eq(
          # amount * number of bills of lading
          18
        )

        cargo_unit_1_payload_in_tons = (cargo_item_1_payload / 1_000).ceil

        expect(node_tree.dig(:children, 1, :children, 4, :children, 0, :amount)).to eq(
          # BigDecimal("47.0") * cargo_unit_1_payload_in_tons * 2
          188
        )
        expect(node_tree.dig(:children, 1, :children, 4, :children, 1, :amount)).to eq(
          # BigDecimal("42.0") * cargo_unit_1_payload_in_tons * 2
          168
        )
        expect(node_tree.dig(:children, 1, :children, 4, :children, 2, :amount)).to eq(
          # BigDecimal("5.5") * cargo_item_1_volume * 2
          11
        )
        expect(node_tree.dig(:children, 1, :children, 4, :children, 3, :amount)).to eq(
          # BigDecimal("25.0") * 2
          50
        )
      end
    end
  end
end
