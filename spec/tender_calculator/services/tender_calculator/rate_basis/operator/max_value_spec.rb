# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::RateBasis::Operator::MaxValue do
  let(:cargo_rate) { FactoryBot.build(:rates_cargo, operator: operator, cbm_ratio: 0) }
  let(:kg_based_fee) { FactoryBot.create(:kg_based_fee, cargo: cargo_rate, amount_cents: 1000) }
  let(:cbm_based_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_rate, amount_cents: 1500) }

  let(:cargo_unit) { FactoryBot.build(:lcl_unit, weight_value: 30, volume_value: 40, quantity: 2) }
  let(:targeted_rate) { RateExtractor::Decorators::CargoRate.new(cargo_rate) }
  let(:rate_charged_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo_unit, context: {rate: cargo_rate}) }

  let(:calculated_cargo_rate) { TenderCalculator::CargoRate.new(cargo_rate: targeted_rate, cargo: rate_charged_cargo) }

  before do
    targeted_rate.targets = [rate_charged_cargo]
  end

  context "when cargo rate operator is max_value" do
    let(:operator) { :max_value }

    it "calculates line item as the maximum value of the multiple children fees" do
      expected_amount = [kg_based_fee.amount * 60, cbm_based_fee.amount * 80].max

      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
