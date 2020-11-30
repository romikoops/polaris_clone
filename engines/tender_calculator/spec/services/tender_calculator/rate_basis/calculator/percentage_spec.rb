# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::RateBasis::Calculator::Percentage do
  include_context "when calculator"

  context "when fee is percentage" do
    let(:calculated_cargo_rate) {
      TenderCalculator::CargoRate.new(cargo_rate: targeted_rate.object,
                                      cargo: target_cargo)
    }
    let(:perentage_based_fee) { FactoryBot.create(:rates_fee, :percentage_basis, cargo: cargo_rate, percentage: 100) }

    it "calculates the line item value as the fee value" do
      expected_amount = perentage_based_fee.percentage
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
