# frozen_string_literal: true

require "spec_helper"

RSpec.describe ChargeCalculator::Calculation do
  context "result" do
    let(:rates) do
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
        }
      ]
    end

    let(:context) do
      {
        quantity:           2,
        payload:            BigDecimal("255.0"),
        chargeable_payload: BigDecimal("255.0"),
        dimensions:         {
          x: "100.0",
          y: "100.0",
          z: "100.0"
        }
      }
    end

    let(:calculation) { described_class.new(rates: rates, context: context) }

    it "Returns an array of arrays" do
      expect(calculation.result).to be_a Array
      expect(calculation.result).to all be_a Hash
    end

    context "weight steps" do
      it "Calculates the correct price" do
        expect(calculation.result).to eq(
          [{
            amount:   BigDecimal("23.42") * BigDecimal("255.0") * 2,
            currency: "EUR",
            category: "BAS"
          }]
        )
      end
    end
  end
end
