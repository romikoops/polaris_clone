# frozen_string_literal: true

require "rails_helper"

RSpec.shared_examples "ChargeCalculator Single Component" do
  it "calculates the fee correctly", :aggregate_failures do
    expect(results.length).to eq(1)
    expect(results.first.value).to eq(expected_value)
  end
end

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
  let(:measures) do
    OfferCalculator::Service::Measurements::Cargo.new(
      engine: OfferCalculator::Service::Measurements::Engines::Unit.new(
        cargo_unit: cargo_unit,
        scope: {},
        object: manipulated_result
      ),
      scope: {},
      object: manipulated_result
    )
  end
  let(:min_value) { Money.new(0, "USD") }
  let(:max_value) { Money.new(1e12, "USD") }
  let(:rate_builder_fee) do
    FactoryBot.build(:rate_builder_fee,
      min_value: min_value,
      max_value: max_value,
      rate_basis: fee.rate_basis.internal_code,
      targets: measures.cargo_units,
      measures: measures,
      charge_category: fee.charge_category,
      raw_fee: fee.fee_data)
  end
  let(:fees) { [rate_builder_fee] }
  let(:results) { described_class.charges(request: request, fees: fees) }
  let(:percentage_fee) do
    FactoryBot.build(:rate_builder_fee,
      min_value: min_value,
      rate_basis: "PERCENTAGE",
      targets: nil,
      measures: measures,
      charge_category: FactoryBot.create(:puf_charge),
      raw_fee: { rate: 0.1, rate_basis: "PERCENTAGE" })
  end

  context "when calculating per_wm fee" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:expected_value) { measures.wm.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_wm fee with flat margin" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:flat_margins) { { fee.charge_category.code => 50 } }
    let(:expected_value) { measures.wm.value * Money.new(fee.rate * 100, fee.currency_name) + flat_margin_value }
    let(:flat_margin_value) { Money.new(5000, "USD") }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_container fee" do
    let(:fee) { FactoryBot.create(:fee_per_container, pricing: pricing) }
    let(:cargo_unit) do
      FactoryBot.build(:journey_cargo_unit,
        cargo_class: "fcl_20",
        quantity: 2,
        weight_value: 12_000)
    end
    let(:expected_value) { measures.unit.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_hbl fee" do
    let(:fee) { FactoryBot.create(:fee_per_hbl, pricing: pricing) }
    let(:expected_value) { measures.shipment.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_shipment fee" do
    let(:fee) { FactoryBot.create(:fee_per_shipment, pricing: pricing) }
    let(:expected_value) { measures.shipment.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_item fee" do
    let(:fee) { FactoryBot.create(:fee_per_item, pricing: pricing) }
    let(:expected_value) { measures.unit.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_cbm fee" do
    let(:fee) { FactoryBot.create(:fee_per_cbm, pricing: pricing) }
    let(:expected_value) { measures.cbm.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_kg fee" do
    let(:fee) { FactoryBot.create(:fee_per_kg, pricing: pricing) }
    let(:expected_value) { measures.kg.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_x_kg_flat fee" do
    let(:fee) { FactoryBot.create(:fee_per_x_kg_flat, pricing: pricing) }
    let(:rate_value) { (measures.kg.value / fee.base).ceil * fee.base }
    let(:expected_value) { Money.new(rate_value * fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_ton fee" do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
    let(:expected_value) { measures.ton.value * Money.new(fee.rate * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating per_ton with base fee" do
    let(:fee) { FactoryBot.create(:fee_per_ton, base: 0.1, pricing: pricing) }
    let(:expected_value) { Money.new((measures.ton.value / fee.base).ceil * fee.rate * fee.base * 100, fee.currency_name) }

    include_examples "ChargeCalculator Single Component"
  end

  context "when calculating percentage fee" do
    let(:fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
    let(:expected_rate_value) { measures.wm.value * fee.rate * 0.1 }

    before do
      fees << percentage_fee
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
      fees << percentage_fee
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
      expect(results.first.value).to eq(min_value)
    end
  end

  context "when the maximum is hit" do
    let(:fee) { FactoryBot.create(:fee_per_ton, pricing: pricing) }
    let(:max_value) { Money.new(100, "USD") }

    it "calculates the per_ton fee correctly" do
      expect(results.first.value).to eq(max_value)
    end
  end

  context "when an error occurs" do
    let(:fees) { nil }

    it "calculates the per_ton fee correctly" do
      expect { results }.to raise_error(OfferCalculator::Errors::CalculationError)
    end
  end
end
