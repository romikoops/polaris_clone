# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ChargeCalculator::Main do
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

  let(:cargo_item_2) do
    {
      id: 2,
      quantity: 1,
      payload: '540.0',
      dimensions: {
        x: '80.0',
        y: '70.0',
        z: '50.0'
      },
      goods_value: '850.00'
    }
  end

  let(:rates_weight_steps_1) do
    [
      {
        min_price: '20.0',
        currency: 'EUR',
        category: 'BAS',
        kind: 'cargo_unit',
        prices: [
          {
            rule: { between: { field: 'payload', from: 0, to: 400 } },
            amount: '29.35',
            basis: 'chargeable_payload'
          },
          {
            rule: { between: { field: 'payload', from: 401, to: 800 } },
            amount: '25.78',
            basis: 'chargeable_payload'
          },
          {
            rule: { between: { field: 'payload', from: 801, to: 1_500 } },
            amount: '23.42',
            basis: 'chargeable_payload'
          }
        ]
      },
      {
        min_price: '20.0',
        currency: 'EUR',
        category: 'HAS',
        kind: 'cargo_unit',
        prices: [
          {
            rule: nil,
            amount: '20.0',
            basis: 'chargeable_payload'
          }
        ]
      }
    ]
  end
  let(:rates_weight_steps_2) do
    [
      {
        min_price: '5.0',
        currency: 'EUR',
        category: 'BAS',
        kind: 'cargo_unit',
        prices: [
          {
            rule: { between: { field: 'payload', from: 0, to: 580 } },
            amount: '49.25',
            basis: 'chargeable_payload'
          },
          {
            rule: { between: { field: 'payload', from: 581, to: 1_400 } },
            amount: '33.58',
            basis: 'chargeable_payload'
          },
          {
            rule: { between: { field: 'payload', from: 1_401, to: 2_500 } },
            amount: '28.64',
            basis: 'chargeable_payload'
          }
        ]
      }
    ]
  end
  let(:rates_100_kg_basis) do
    [
      {
        min_price: '30.0',
        currency: 'EUR',
        category: 'BAS',
        kind: 'cargo_unit',
        prices: [
          {
            rule: nil,
            amount: '51.25',
            basis: 'payload_unit_100_kg'
          }
        ]
      }
    ]
  end

  let(:rate_flat_per_shipment) do
    {
      min_price: '30.0',
      currency: 'EUR',
      category: 'flat_fees',
      kind: 'shipment',
      prices: [
        {
          rule: nil,
          amount: '200.0',
          basis: 'flat'
        }
      ]
    }
  end

  let(:rates_weight_steps_1_and_flat_per_shipment) do
    [
      rates_weight_steps_1.first,
      rate_flat_per_shipment
    ]
  end

  context '2 Connected Ocean Routes' do
    context 'Weight Steps' do
      subject { described_class.new(shipment_params: shipment_params, pricings: pricings) }

      let(:pricings) do
        [
          {
            conversion_ratios: {
              weight_measure: '1_000.0'
            },
            route: 'Hamburg - Gothenburg',
            rates: rates_weight_steps_1
          },
          {
            conversion_ratios: {
              weight_measure: '1_000.0'
            },
            route: 'Gothenburg - Shanghai',
            rates: rates_weight_steps_2
          }
        ]
      end

      let(:shipment_params) do
        {
          load_type: 'cargo_item',
          cargo_units: [
            cargo_item_1,
            cargo_item_2
          ]
        }
      end

      describe '#price' do
        it 'calculates the correct price node tree' do
          expect(subject.price).to be_a ChargeCalculator::Models::Price

          node_tree = subject.price.to_h
          expect(node_tree.to_json).to match_json_schema('main/price')

          # cargo_item_1_payload = BigDecimal(cargo_item_1[:payload])
          # cargo_item_2_payload = BigDecimal(cargo_item_2[:payload])

          expect(node_tree.dig(:children, 0, :children, 0, :children, 0, :amount)).to eq(
            # cargo_item_1_payload * BigDecimal("23.42") * 2
            52_929.2
          )
          expect(node_tree.dig(:children, 0, :children, 0, :children, 1, :amount)).to eq(
            # cargo_item_1_payload * BigDecimal("20.0") * 2
            45_200
          )
          expect(node_tree.dig(:children, 0, :children, 1, :children, 0, :amount)).to eq(
            # cargo_item_2_payload * BigDecimal("25.78")
            13_921.2
          )
          expect(node_tree.dig(:children, 0, :children, 1, :children, 1, :amount)).to eq(
            # cargo_item_2_payload * BigDecimal("20.0")
            10_800
          )

          expect(node_tree.dig(:children, 1, :children, 0, :children, 0, :amount)).to eq(
            # cargo_item_1_payload * BigDecimal("33.58") * 2
            75_890.8
          )
          expect(node_tree.dig(:children, 1, :children, 1, :children, 0, :amount)).to eq(
            # cargo_item_2_payload * BigDecimal("49.25")
            26_595
          )
        end
      end
    end

    context '100 Kg Basis (route 1), Weight Steps (route 2)' do
      subject { described_class.new(shipment_params: shipment_params, pricings: pricings) }

      let(:pricings) do
        [
          {
            conversion_ratios: {
              weight_measure: '1_000.0'
            },
            route: 'Hamburg - Gothenburg',
            rates: rates_100_kg_basis
          },
          {
            conversion_ratios: {
              weight_measure: '1_000.0'
            },
            route: 'Gothenburg - Shanghai',
            rates: rates_weight_steps_2
          }
        ]
      end

      let(:shipment_params) do
        {
          load_type: 'cargo_item',
          cargo_units: [
            cargo_item_1,
            cargo_item_2
          ]
        }
      end

      describe '#price' do
        it 'calculates the correct price node tree' do
          expect(subject.price).to be_a ChargeCalculator::Models::Price

          node_tree = subject.price.to_h
          expect(node_tree.to_json).to match_json_schema('main/price')

          # cargo_item_1_payload = BigDecimal(cargo_item_1[:payload])
          # cargo_item_2_payload = BigDecimal(cargo_item_2[:payload])

          expect(node_tree.dig(:children, 0, :children, 0, :children, 0, :amount)).to eq(
            # (cargo_item_1_payload / 100).ceil * BigDecimal("51.25") * 2
            1_230
          )
          expect(node_tree.dig(:children, 0, :children, 1, :children, 0, :amount)).to eq(
            # (cargo_item_2_payload / 100).ceil * BigDecimal("51.25") * 1
            307.5
          )

          expect(node_tree.dig(:children, 1, :children, 0, :children, 0, :amount)).to eq(
            # cargo_item_1_payload * BigDecimal("33.58") * 2
            75_890.8
          )
          expect(node_tree.dig(:children, 1, :children, 1, :children, 0, :amount)).to eq(
            # cargo_item_2_payload * BigDecimal("49.25")
            26_595
          )
        end
      end
    end
  end

  context '1 Route Ocean Route' do
    context '100 Kg Basis (route 1), Weight Steps (route 2)' do
      subject { described_class.new(shipment_params: shipment_params, pricings: pricings) }

      let(:pricings) do
        [
          {
            conversion_ratios: {
              weight_measure: '1_000.0'
            },
            route: 'Hamburg - Gothenburg',
            rates: rates_weight_steps_1_and_flat_per_shipment
          }
        ]
      end

      let(:shipment_params) do
        {
          load_type: 'cargo_item',
          cargo_units: [
            cargo_item_1,
            cargo_item_2
          ]
        }
      end

      describe '#price' do
        it 'calculates the correct price node tree' do
          expect(subject.price).to be_a ChargeCalculator::Models::Price

          node_tree = subject.price.to_h
          expect(node_tree.to_json).to match_json_schema('main/price')

          # cargo_item_1_payload = BigDecimal(cargo_item_1[:payload])
          # cargo_item_2_payload = BigDecimal(cargo_item_2[:payload])

          expect(node_tree.dig(:children, 0, :children, 0, :amount)).to eq(
            200
          )

          expect(node_tree.dig(:children, 0, :children, 1, :children, 0, :amount)).to eq(
            # cargo_item_1_payload * BigDecimal("23.42") * 2
            52_929.2
          )
          expect(node_tree.dig(:children, 0, :children, 2, :children, 0, :amount)).to eq(
            # cargo_item_2_payload * BigDecimal("25.78")
            13_921.2
          )
        end
      end
    end
  end
end
