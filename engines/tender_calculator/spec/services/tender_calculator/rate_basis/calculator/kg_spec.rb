# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenderCalculator::RateBasis::Calculator::Kg do
  include_context 'when calculator'

  context 'when fee is per kg' do
    let(:calculated_cargo_rate) { TenderCalculator::CargoRate.new(cargo_rate: cargo_rate, cargo: target_cargo) }
    let(:kg_based_fee) { FactoryBot.create(:kg_based_fee, cargo: cargo_rate, amount_cents: 70) }

    it 'calculates the line item value as the fee value * chargeable weight of the cargo' do
      expected_amount = kg_based_fee.amount * target_cargo.chargeable_weight.value
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
