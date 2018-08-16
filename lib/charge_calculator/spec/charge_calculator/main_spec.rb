# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChargeCalculator::Main do
  let(:rates_weight_steps_1) do
    [
      {
        min_price: "20.0",
        currency:  "EUR",
        category:  "BAS",
        prices:    [
          {
            rule:   { between: { field: "payload", from: 0, to: 100 } },
            amount: "29.35",
            basis:  "chargeable_payload"
          },
          {
            rule:   { between: { field: "payload", from: 100, to: 200 } },
            amount: "25.78",
            basis:  "chargeable_payload"
          },
          {
            rule:   { between: { field: "payload", from: 200, to: 300 } },
            amount: "23.42",
            basis:  "chargeable_payload"
          }
        ]
      },
      {
        min_price: "20.0",
        currency:  "EUR",
        category:  "HAS",
        prices:    [
          {
            rule:   nil,
            amount: "20.0",
            basis:  "chargeable_payload"
          }
        ]
      }
    ]
  end
  let(:rates_weight_steps_2) do
    [
      {
        min_price: "5.0",
        currency:  "EUR",
        category:  "BAS",
        prices:    [
          {
            rule:   { between: { field: "payload", from: 0, to: 150 } },
            amount: "49.25",
            basis:  "chargeable_payload"
          },
          {
            rule:   { between: { field: "payload", from: 151, to: 300 } },
            amount: "33.58",
            basis:  "chargeable_payload"
          },
          {
            rule:   { between: { field: "payload", from: 301, to: 500 } },
            amount: "28.64",
            basis:  "chargeable_payload"
          }
        ]
      }
    ]
  end

  context "2 Connected Ocean Routes" do
    context "Weight Steps" do
      let(:pricings) do
        [
          {
            conversion_ratios: {
              weight_measure: "1.0"
            },
            route:             "Hamburg - Gothenburg",
            rates:             rates_weight_steps_1
          },
          {
            conversion_ratios: {
              weight_measure: "1.0"
            },
            route:             "Gothenburg - Shanghai",
            rates:             rates_weight_steps_2
          }
        ]
      end

      let(:shipment_params) do
        {
          load_type:   "cargo_item",
          cargo_units: [
            {
              id:         1,
              quantity:   2,
              payload:    "230.0",
              dimensions: {
                x: "100.0",
                y: "100.0",
                z: "100.0"
              }
            },
            {
              id:         2,
              quantity:   1,
              payload:    "140.0",
              dimensions: {
                x: "80.0",
                y: "70.0",
                z: "50.0"
              }
            }
          ]
        }
      end

      subject { described_class.new(shipment_params: shipment_params, pricings: pricings) }

      context "price" do
        it "calculates the correct price node tree" do
          expect(subject.price).to be_a ChargeCalculator::Price

          node_tree = subject.price.to_nested_hash
          expect(node_tree.to_json).to match_json_schema("main/price")

          expect(node_tree.dig(:children, 0, :children, 0, :children, 0, :amount)).to eq(
            BigDecimal("230.0") * BigDecimal("23.42") * 2
          )
          expect(node_tree.dig(:children, 0, :children, 0, :children, 1, :amount)).to eq(
            BigDecimal("230.0") * BigDecimal("20.0") * 2
          )
          expect(node_tree.dig(:children, 0, :children, 1, :children, 0, :amount)).to eq(
            BigDecimal("140.0") * BigDecimal("25.78")
          )
          expect(node_tree.dig(:children, 0, :children, 1, :children, 1, :amount)).to eq(
            BigDecimal("140.0") * BigDecimal("20.0")
          )

          expect(node_tree.dig(:children, 1, :children, 0, :children, 0, :amount)).to eq(
            BigDecimal("230.0") * BigDecimal("33.58") * 2
          )
          expect(node_tree.dig(:children, 1, :children, 1, :children, 0, :amount)).to eq(
            BigDecimal("140.0") * BigDecimal("49.25")
          )
        end
      end
    end
  end
end
