# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Calculators::Charge do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:pricing_fee) { pricing.fees.first }
  let(:charge_category) { pricing_fee.charge_category }
  let(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:cargo) do
    FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
      FactoryBot.create(:lcl_unit, cargo: tapped_cargo)
    end
  end
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Unit.new(
      cargo: cargo.units.first,
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
  let(:value) { Money.new(2500, "USD") }
  let(:rate) { Money.new(pricing_fee.rate * 100.0, pricing_fee.currency_name) }
  let(:min_value) { Money.new(pricing_fee.min * 100.0, pricing_fee.currency_name) }

  describe "it creates a valid Charge object" do
    let!(:charge) do
      described_class.new(
        value: value,
        fee: fee,
        fee_component: fee.components.first
      )
    end

    it "returns the charge category" do
      expect(charge.charge_category).to eq(charge_category)
    end

    it "returns the target" do
      expect(charge.cargo).to eq(cargo.units.first)
    end

    it "returns the min value" do
      expect(charge.min_value).to eq(fee.min_value)
    end

    it "returns the rate" do
      expect(charge.rate).to eq(rate)
    end

    it "returns the fee" do
      expect(charge.fee).to eq(fee)
    end

    it "returns the value" do
      expect(charge.value).to eq(value)
    end
  end
end
