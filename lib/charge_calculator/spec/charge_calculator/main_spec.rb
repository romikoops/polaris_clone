# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChargeCalculator::Main do
  let(:cargo_item_1) do
    {
      id:         1,
      quantity:   2,
      payload:    "230.0",
      dimensions: {
        x: "100.0",
        y: "100.0",
        z: "100.0"
      }
    }
  end

  let(:cargo_item_2) do
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
  end


  context "Dummy test cases" do
    let(:rates_weight_steps_1) do
      [
        {
          min_price: "20.0",
          currency:  "EUR",
          category:  "BAS",
          kind:      "cargo_unit",
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
          kind:      "cargo_unit",
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
          kind:      "cargo_unit",
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
    let(:rates_100_kg_basis) do
      [
        {
          min_price: "30.0",
          currency:  "EUR",
          category:  "BAS",
          kind:      "cargo_unit",
          prices:    [
            {
              rule:   nil,
              amount: "51.25",
              basis:  "payload_unit_100_kg"
            }
          ]
        }
      ]
    end

    let(:rate_flat_per_shipment) do
      {
        min_price: "30.0",
        currency:  "EUR",
        category:  "flat_fees",
        kind:      "shipment",
        prices:    [
          {
            rule:   nil,
            amount: "200.0",
            basis:  "flat"
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
              cargo_item_1,
              cargo_item_2
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

      context "100 Kg Basis (route 1), Weight Steps (route 2)" do
        let(:pricings) do
          [
            {
              conversion_ratios: {
                weight_measure: "1.0"
              },
              route:             "Hamburg - Gothenburg",
              rates:             rates_100_kg_basis
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
              cargo_item_1,
              cargo_item_2
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
              3 * BigDecimal("51.25") * 2
            )
            expect(node_tree.dig(:children, 0, :children, 1, :children, 0, :amount)).to eq(
              2 * BigDecimal("51.25") * 1
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

    context "1 Route Ocean Route" do
      context "100 Kg Basis (route 1), Weight Steps (route 2)" do
        let(:pricings) do
          [
            {
              conversion_ratios: {
                weight_measure: "1.0"
              },
              route:             "Hamburg - Gothenburg",
              rates:             rates_weight_steps_1_and_flat_per_shipment
            }
          ]
        end

        let(:shipment_params) do
          {
            load_type:   "cargo_item",
            cargo_units: [
              cargo_item_1,
              cargo_item_2
            ]
          }
        end

        subject { described_class.new(shipment_params: shipment_params, pricings: pricings) }

        context "price" do
          it "calculates the correct price node tree" do
            expect(subject.price).to be_a ChargeCalculator::Price

            node_tree = subject.price.to_nested_hash
            expect(node_tree.to_json).to match_json_schema("main/price")

            expect(node_tree.dig(:children, 0, :children, 0, :amount)).to eq(
              BigDecimal("200.0")
            )

            expect(node_tree.dig(:children, 0, :children, 1, :children, 0, :amount)).to eq(
              BigDecimal("230.0") * BigDecimal("23.42") * 2
            )
            expect(node_tree.dig(:children, 0, :children, 2, :children, 0, :amount)).to eq(
              BigDecimal("140.0") * BigDecimal("25.78")
            )
          end
        end
      end
    end
  end

  context "Real test cases" do
    let(:rates_japan_freight) do
      # Source
      # Japan_SEARATES_USD
      # https://docs.google.com/spreadsheets/d/1XGoGGpzxp76lp8J89TxOxyL6k_G5sa0JzbYXPqR12Yo/edit#gid=823988371

      [
        {
          min_price: "19.0",
          currency:  "USD",
          category:  "BAS",
          kind:      "cargo_unit",
          prices:    [
            {
              rule:   nil,
              amount: "19.0",
              basis:  "weight_measure"
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
          min_price: "47.0",
          currency:  "USD",
          category:  "THC",
          kind:      "cargo_unit",
          reducer:   "sum",
          prices:    [
            {
              rule:   nil,
              amount: "47.0",
              basis:  "ton"
            },
            {
              rule:   { equal: { field: "telegraphic_transfer", arg_value: true } },
              amount: "44.0",
              basis:  "flat"
            }
          ]
        },
        {
          min_price: "42.0",
          currency:  "USD",
          category:  "LCL",
          kind:      "cargo_unit",
          prices:    [
            {
              rule:   nil,
              amount: "42.0",
              basis:  "ton"
            }
          ]
        },
        {
          min_price: "5.0",
          currency:  "USD",
          category:  "ANT",
          kind:      "shipment",
          prices:    [
            {
              rule:   nil,
              amount: "5.0",
              basis:  "flat"
            }
          ]
        },
        {
          min_price: "2.5",
          currency:  "USD",
          category:  "BL",
          kind:      "shipment",
          prices:    [
            {
              rule:   nil,
              amount: "2.5",
              basis:  "bill_of_lading"
            }
          ]
        },
        {
          min_price: "35.0",
          currency:  "USD",
          category:  "AFR",
          kind:      "shipment",
          prices:    [
            {
              rule:   nil,
              amount: "35.0",
              basis:  "flat"
            }
          ]
        },
        {
          min_price: "5.5",
          currency:  "USD",
          category:  "ISP",
          kind:      "cargo_unit",
          prices:    [
            {
              rule:   nil,
              amount: "5.5",
              basis:  "volume"
            }
          ]
        },
        {
          min_price: "18.0",
          currency:  "USD",
          category:  "VGM",
          kind:      "shipment",
          prices:    [
            {
              rule:   nil,
              amount: "18.0",
              basis:  "bill_of_lading"
            }
          ]
        },
        {
          min_price: "25.0",
          currency:  "USD",
          category:  "CUST",
          kind:      "cargo_unit",
          prices:    [
            {
              rule:   { gt: { field: "goods_value", arg_value: 1000 } },
              amount: "25.0",
              basis:  "flat"
            }
          ]
        }
      ]
    end

    context "1 Route Ocean Route" do
      let(:pricings) do
        [
          {
            conversion_ratios: {
              weight_measure: "1.0"
            },
            route:             "Tokyo - Hamburg",
            rates:             rates_japan_freight
          },
          {
            conversion_ratios: {
              weight_measure: "1.0"
            },
            route:             "Tokyo - Hamburg",
            direction:         "Export",
            rates:             rates_japan_local_charges
          }
        ]
      end

      let(:shipment_params) do
        {
          load_type:   "cargo_item",
          cargo_units: [cargo_item_1]
        }
      end

      subject { described_class.new(shipment_params: shipment_params, pricings: pricings) }

      context "price" do
        it "calculates the correct price node tree" do
          expect(subject.price).to be_a ChargeCalculator::Price

          node_tree = subject.price.to_nested_hash
          expect(node_tree.to_json).to match_json_schema("main/price")

          # TODO: Add needle specs
        end
      end
    end
  end
end
