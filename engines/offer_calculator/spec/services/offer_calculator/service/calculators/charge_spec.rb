# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Calculators::Charge do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:pricing_fee) { pricing.fees.first }
  let(:charge_category) { pricing_fee.charge_category }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:measures) do
    FactoryBot.build(:measurements_cargo, scope: {}, manipulated_result: manipulated_result)
  end
  let(:fee) do
    FactoryBot.build(:rate_builder_fee,
      charge_category: charge_category,
      raw_fee: pricing_fee.fee_data,
      min_value: min_value,
      measures: measures,
      targets: measures.cargo_units)
  end
  let(:value) { Money.new(2500, "USD") }
  let(:rate) { Money.new(pricing_fee.rate * 100.0, pricing_fee.currency_name) }
  let(:min_value) { Money.new(pricing_fee.min * 100.0, pricing_fee.currency_name) }
  let!(:charge) do
    described_class.new(
      value: value,
      fee: fee,
      fee_component: fee.components.first
    )
  end

  describe "#charge_category" do
    it "returns the charge category" do
      expect(charge.charge_category).to eq(charge_category)
    end
  end

  describe "#targets" do
    it "returns the targets" do
      expect(charge.targets).to eq(measures.cargo_units)
    end
  end

  describe "#min_value" do
    it "returns the min value" do
      expect(charge.min_value).to eq(fee.min_value)
    end
  end

  describe "#rate" do
    it "returns the rate" do
      expect(charge.rate).to eq(rate)
    end
  end

  describe "#fee" do
    it "returns the fee" do
      expect(charge.fee).to eq(fee)
    end
  end

  describe "#tenant_vehicle" do
    it "returns the Legacy::TenantVehicle from the Charge" do
      expect(charge.tenant_vehicle).to eq(pricing.tenant_vehicle)
    end
  end

  describe "#rounded_value" do
    it "returns the value as is when there are no fractional cents" do
      expect(charge.rounded_value).to eq(value)
    end

    context "when the charge value is a fraction of the currency's base unit" do
      let(:value) { Money.new(0.75, "USD") }

      it "rounds the value to the nearest cent" do
        expect(charge.rounded_value).to eq(Money.new(1, "USD"))
      end
    end
  end

  describe "#unit_value" do
    before { allow(fee).to receive(:quantity).and_return(2) }

    it "returns the value divided by the number of units" do
      expect(charge.unit_value).to eq(Money.new(1250, "USD"))
    end

    context "when the charge unit_value results in a fraction of the currency's base unit" do
      let(:value) { Money.new(25, "USD") }

      it "rounds the value to the nearest cent" do
        expect(charge.unit_value).to eq(Money.new(13, "USD"))
      end
    end
  end
end
