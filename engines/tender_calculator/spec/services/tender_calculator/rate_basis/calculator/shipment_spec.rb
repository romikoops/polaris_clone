# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::RateBasis::Calculator::Shipment do
  include_context "when calculator"

  context "when fee is per shipment" do
    let(:calculated_cargo_rate) {
      TenderCalculator::CargoRate.new(cargo_rate: targeted_rate.object,
                                      cargo: target_cargo)
    }
    let(:shipment_based_fee) { FactoryBot.create(:rates_fee, :shipment_basis, cargo: cargo_rate, amount_cents: 100) }

    it "calculates the line item value as the fee value" do
      expected_amount = shipment_based_fee.amount
      expect(calculated_cargo_rate.value).to eq expected_amount
    end
  end
end
