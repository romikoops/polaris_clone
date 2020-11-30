# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::RateBasis::Calculator::Stowage do
  include_context "when calculator"

  context "when fee is per stowage factor" do
    let(:calculated_cargo_rate) {
      TenderCalculator::CargoRate.new(cargo_rate: targeted_rate.object,
                                      cargo: target_cargo)
    }
    let(:stowage_based_fee) { FactoryBot.create(:stowage_based_fee, cargo: cargo_rate, amount_cents: 10) }

    it "calculates the line item value as the fee value * stowage factor of the cargo" do
      expected_amount = stowage_based_fee.amount * target_cargo.stowage_factor.value
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
