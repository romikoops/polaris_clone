# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::ChargeCalculator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:cargo_unit) do
    FactoryBot.build(:journey_cargo_unit,
      width_value: 1.20,
      height_value: 1.40,
      length_value: 0.8,
      quantity: 2,
      weight_value: 1200)
  end

  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json,
      flat_margins: flat_margins)
  end
  let(:flat_margins) { {} }
  let(:engine) do
    OfferCalculator::Service::Measurements::Engines::Unit.new(
      cargo_unit: cargo_unit,
      scope: {},
      object: manipulated_result
    )
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Cargo.new(
      engine: engine,
      scope: {},
      object: manipulated_result
    )
  end
  let(:min_value) { Money.new(0, "USD") }
  let(:max_value) { Money.new(1e12, "USD") }
  let(:fee_data) { fee.fee_data }
  let(:rate_builder_fee) do
    FactoryBot.build(:rate_builder_fee,
      min_value: min_value,
      max_value: max_value,
      rate_basis: fee.rate_basis.internal_code,
      targets: measures.cargo_units,
      measures: measures,
      charge_category: fee.charge_category,
      raw_fee: fee_data)
  end
  let(:fees) { [rate_builder_fee] }
  let(:results) { described_class.charges(request: request, fees: fees) }

  context "when calculating per_wm fee" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }

    it "calculates the per_wm fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.wm.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_wm fee with flat margin" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:flat_margins) { {fee.charge_category.code => 50} }
    let(:expected_value) { measures.wm.value * Money.new(fee.rate * 100, fee.currency_name) }
    let(:flat_margin_value) { Money.new(5000, "USD") }

    it "calculates the per_wm fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(expected_value + flat_margin_value)
      end
    end
  end

  context "when calculating per_container fee" do
    let(:fee) { FactoryBot.create(:fee_per_container, pricing: pricing) }
    let(:cargo_unit) do
      FactoryBot.build(:journey_cargo_unit,
        cargo_class: "fcl_20",
        quantity: 2,
        weight_value: 12_000)
    end

    it "calculates the per_container fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.unit.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_hbl fee" do
    let(:fee) { FactoryBot.create(:fee_per_hbl, pricing: pricing) }

    it "calculates the per_hbl fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.shipment.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_shipment fee" do
    let(:fee) { FactoryBot.create(:fee_per_shipment, pricing: pricing) }

    it "calculates the per_shipment fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.shipment.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_item fee" do
    let(:fee) { FactoryBot.create(:fee_per_item, pricing: pricing) }

    it "calculates the per_item fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.unit.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_cbm fee" do
    let(:fee) { FactoryBot.create(:fee_per_cbm, pricing: pricing) }

    it "calculates the per_cbm fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.cbm.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_kg fee" do
    let(:fee) { FactoryBot.create(:fee_per_kg, pricing: pricing) }

    it "calculates the per_kg fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.kg.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_x_kg_flat fee" do
    let(:fee) { FactoryBot.create(:fee_per_x_kg_flat, pricing: pricing) }
    let(:rate_value) { (measures.kg.value / fee.base).ceil * fee.base }

    it "calculates the per_x_kg_flat fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(rate_value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating per_ton fee" do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }

    it "calculates the per_ton fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(Money.new(measures.ton.value * fee.rate * 100, fee.currency_name))
      end
    end
  end

  context "when calculating percentage fee" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:expected_rate_value) { measures.wm.value * fee.rate * 0.1 }

    before do
      fees << FactoryBot.build(:rate_builder_fee,
        min_value: min_value,
        rate_basis: "PERCENTAGE",
        targets: nil,
        measures: measures,
        charge_category: FactoryBot.create(:puf_charge),
        raw_fee: {rate: 0.1, rate_basis: "PERCENTAGE"})
    end

    it "calculates the per_ton fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(2)
        expect(results.second.value).to eq(Money.new(expected_rate_value * 100, fee.currency_name))
      end
    end
  end

  context "when calculating percentage fee with min value" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:min_value) { Money.new(12_000_000, "USD") }

    before do
      fees << FactoryBot.build(:rate_builder_fee,
        min_value: min_value,
        rate_basis: "PERCENTAGE",
        targets: nil,
        measures: measures,
        charge_category: FactoryBot.create(:puf_charge),
        raw_fee: {rate: 0.1, rate_basis: "PERCENTAGE"})
    end

    it "calculates the per_ton fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(2)
        expect(results.second.value).to eq(min_value)
      end
    end
  end

  context "when the minimum is hit" do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
    let(:min_value) { Money.new(12_000_000, "USD") }

    it "calculates the per_ton fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(min_value)
      end
    end
  end

  context "when the maximum is hit" do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
    let(:max_value) { Money.new(100, "USD") }

    it "calculates the per_ton fee correctly" do
      aggregate_failures do
        expect(results.length).to eq(1)
        expect(results.first.value).to eq(max_value)
      end
    end
  end

  context "when an error occurs" do
    let(:fees) { nil }

    it "calculates the per_ton fee correctly" do
      expect { results }.to raise_error(OfferCalculator::Errors::CalculationError)
    end
  end
end
