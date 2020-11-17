# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenderCalculator::RateBasis::Calculator::Km do
  include_context 'when calculator'

  context 'when fee is per km' do
    let(:calculated_cargo_rate) { TenderCalculator::CargoRate.new(cargo_rate: cargo_rate, cargo: target_cargo) }
    let(:km_based_fee) { FactoryBot.create(:km_based_fee, cargo: cargo_rate, amount_cents: 70) }

    before do
      allow(target_cargo).to receive(:route_distance).and_return(6)
    end

    it 'calculates the line item value as the fee value * distance in km between two locations' do
      expected_amount = km_based_fee.amount * 6
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
