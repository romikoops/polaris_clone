# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Calculators::Result do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing_fee) { pricing.fees.first }
  let(:charge_category) { pricing_fee.charge_category }
  let(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:cargo) do
    FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
      FactoryBot.create(:lcl_unit, cargo: tapped_cargo)
    end
  end
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Cargo.new(
      cargo: cargo,
      scope: {},
      object: manipulated_result
    )
  end
  let(:fee) do
    FactoryBot.build(:rate_builder_fee,
      charge_category: charge_category,
      raw_fee: pricing_fee.fee_data,
      min_value: min_value,
      measures: measures,
      target: cargo.units.first)
  end
  let(:rate_builder_result) do
    FactoryBot.build(:rate_builder_result,
      object: manipulated_result,
      measures: measures)
  end
  let(:value) { Money.new(2500, "USD") }
  let(:rate) { Money.new(pricing_fee.rate * 100.0, pricing_fee.currency_name) }
  let(:min_value) { Money.new(pricing_fee.min * 100.0, pricing_fee.currency_name) }

  describe "it creates a valid Charge object" do
    let!(:result) do
      FactoryBot.build(:calculators_result,
        object: manipulated_result,
        measures: measures,
        rate_builder_result: rate_builder_result)
    end

    it "returns the total" do
      expect(result.total).to eq(Money.new(3360, "EUR"))
    end
  end
end
