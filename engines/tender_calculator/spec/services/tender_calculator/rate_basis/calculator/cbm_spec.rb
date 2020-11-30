# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::RateBasis::Calculator::Cbm do
  include_context "when calculator"

  context "when fee is per cbm" do
    let(:calculated_cargo_rate) {
      TenderCalculator::CargoRate.new(cargo_rate: targeted_rate, cargo: targeted_rate.targets.first)
    }
    let(:cbm_based_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_rate, amount_cents: 60) }

    it "calculates the line item value as the fee value * cargo volume" do
      expected_amount = cbm_based_fee.amount * cargo_unit.total_volume.value
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
