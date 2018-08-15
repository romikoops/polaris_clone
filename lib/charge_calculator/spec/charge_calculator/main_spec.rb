# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChargeCalculator::Main do
  let(:pricings) do
    [
      {
        conversion_ratios: {
          weight_measure: "1.0"
        },
        route:             "Hamburg - Gothenburg",
        rates:             [
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
      },
      {
        conversion_ratios: {
          weight_measure: "1.0"
        },
        route:             "Gothenburg - Shanghai",
        rates:             [
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

  let(:main) { described_class.new(shipment_params: shipment_params, pricings: pricings) }

  context "price" do
    it "calculates the correct price node tree" do
      expect(main.price).to be_a ChargeCalculator::Price
      expect(main.price.to_nested_hash).to eq(
        amount:   nil,
        currency: nil,
        category: "Base",
        children: [
          {
            amount:   nil,
            currency: nil,
            category: "Hamburg - Gothenburg",
            children: [
              {
                amount:   nil,
                currency: nil,
                category: "cargo_unit_1",
                children: [
                  {
                    amount:   BigDecimal("230.0") * BigDecimal("23.42") * 2,
                    currency: "EUR",
                    category: "BAS"
                  },
                  {
                    amount:   BigDecimal("230.0") * BigDecimal("20.0") * 2,
                    currency: "EUR",
                    category: "HAS"
                  }
                ]
              },
              {
                amount:   nil,
                currency: nil,
                category: "cargo_unit_2",
                children: [
                  {
                    amount:   BigDecimal("140.0") * BigDecimal("25.78"),
                    currency: "EUR",
                    category: "BAS"
                  },
                  {
                    amount:   BigDecimal("140.0") * BigDecimal("20.0"),
                    currency: "EUR",
                    category: "HAS"
                  }
                ]
              }
            ]
          },
          {
            amount:   nil,
            currency: nil,
            category: "Gothenburg - Shanghai",
            children: [
              {
                amount:   nil,
                currency: nil,
                category: "cargo_unit_1",
                children: [
                  {
                    amount:   BigDecimal("230.0") * BigDecimal("33.58") * 2,
                    currency: "EUR",
                    category: "BAS"
                  }
                ]
              },
              {
                amount:   nil,
                currency: nil,
                category: "cargo_unit_2",
                children: [
                  {
                    amount:   BigDecimal("140.0") * BigDecimal("49.25"),
                    currency: "EUR",
                    category: "BAS"
                  }
                ]
              }
            ]
          }
        ]
      )
    end
  end
end
