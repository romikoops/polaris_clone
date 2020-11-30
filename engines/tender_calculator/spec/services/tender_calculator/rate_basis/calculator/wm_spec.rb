# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::RateBasis::Calculator::Wm do
  include_context "when calculator"

  context "when fee is per weight measure" do
    let(:calculated_cargo_rate) {
      TenderCalculator::CargoRate.new(cargo_rate: targeted_rate.object,
                                      cargo: target_cargo)
    }
    let(:wm_based_fee) { FactoryBot.create(:wm_based_fee, cargo: cargo_rate, amount_cents: 10) }

    it "calculates the line item value as the fee value * weight measure of cargo" do
      expected_amount = wm_based_fee.amount * target_cargo.weight_measure.value
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
