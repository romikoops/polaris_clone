# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenderCalculator::RateBasis::Calculator::Unit do
  include_context 'when calculator'

  context 'when fee is per unit' do
    let(:calculated_cargo_rate) { TenderCalculator::CargoRate.new(cargo_rate: targeted_rate.object, cargo: target_cargo) }
    let(:unit_based) { FactoryBot.create(:unit_based_fee, cargo: cargo_rate, amount_cents: 100) }

    it 'calculates the line item value as the fee value * number of units of cargo' do
      expected_amount = unit_based.amount * target_cargo.quantity
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
