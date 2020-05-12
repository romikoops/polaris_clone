# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenderCalculator::RateBasis::Operator::Default do
  let(:cargo_rate) { FactoryBot.build(:rates_cargo, cbm_ratio: 0) }
  let(:kg_based_fee) { FactoryBot.create(:kg_based_fee, cargo: cargo_rate, amount_cents: 1000) }
  let(:cbm_based_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_rate, amount_cents: 1500) }

  let(:cargo_unit) { FactoryBot.build(:lcl_unit, weight_value: 30, volume_value: 40, quantity: 2) }
  let(:targeted_rate) { RateExtractor::Decorators::CargoRate.new(cargo_rate) }
  let(:rate_charged_cargo) { RateExtractor::Decorators::RateChargedCargo.new(cargo_unit, context: { rate: cargo_rate }) }

  let(:calculated_cargo_rate) { TenderCalculator::CargoRate.new(cargo_rate: targeted_rate, cargo: rate_charged_cargo) }

  before do
    targeted_rate.targets = [rate_charged_cargo]
  end

  context 'when cargo rate operator is default' do
    let(:single_fee) { FactoryBot.create(:kg_based_fee, amount_cents: 1000) }
    let(:targeted_rate) { RateExtractor::Decorators::CargoRate.new(single_fee.cargo) }

    it 'calculates the line item out of the only children fee' do
      expected_amount = single_fee.amount * 60
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end

  context 'when line item value is below minimum value' do
    let(:min_value_fee) { FactoryBot.create(:kg_based_fee, amount_cents: 1000, min_amount_cents: 70_000) }
    let(:targeted_rate) { RateExtractor::Decorators::CargoRate.new(min_value_fee.cargo) }

    it 'calculates the line item value as the minimum value on the fee' do
      expect(calculated_cargo_rate.value).to eq min_value_fee.min_amount
    end
  end

  context 'when line item value is above maximum value' do
    let(:max_value_fee) { FactoryBot.create(:kg_based_fee, cargo: cargo_rate, amount_cents: 10_000, max_amount_cents: 30_000) }
    let(:targeted_rate) { RateExtractor::Decorators::CargoRate.new(max_value_fee.cargo) }

    it 'calculates the line item value as the maximum value on the fee' do
      expect(calculated_cargo_rate.value).to eq max_value_fee.max_amount
    end
  end
end
