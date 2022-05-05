# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Margin do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:margin) do
    described_class.new(
      operator: operator,
      rate: rate,
      source: organization,
      currency: Money::Currency.new("USD")
    )
  end
  let(:input_fee) do
    OfferCalculator::Service::Charges::Fee.new(
      rate: fee_rate,
      charge_category_id: FactoryBot.create(:legacy_charge_categories).id,
      rate_basis: "PER_SHIPMENT",
      base: 0,
      minimum_charge: Money.from_amount(10, "USD"),
      maximum_charge: Money.from_amount(10_000, "USD"),
      range_min: 0,
      range_max: Float::INFINITY,
      surcharge: Money.from_amount(0, "USD")
    )
  end
  let(:fee_rate) { Money.from_amount(100, "USD") }
  let(:output_fee) { margin.apply(input_fee: input_fee) }

  describe "#apply" do
    context "when the operator is '%' and value is positive" do
      let(:operator) { "%" }
      let(:rate) { 0.1 }

      it "returns the rate as Money object scaled as x * (1 + rate)" do
        expect(output_fee.rate).to eq(Money.from_amount(110, "USD"))
      end

      it "returns the minimum_charge as Money object scaled as x * (1 + rate)" do
        expect(output_fee.minimum_charge).to eq(Money.from_amount(11, "USD"))
      end

      it "returns the maximum_charge as Money object scaled as x * (1 + rate)" do
        expect(output_fee.maximum_charge).to eq(Money.from_amount(11_000, "USD"))
      end
    end

    context "when the operator is '%' and value is negative" do
      let(:operator) { "%" }
      let(:rate) { -0.1 }

      it "returns the rate as Money object scaled as x * (1 - rate)" do
        expect(output_fee.rate).to eq(Money.from_amount(90, "USD"))
      end

      it "returns the minimum_charge as Money object scaled as x * (1 - rate)" do
        expect(output_fee.minimum_charge).to eq(Money.from_amount(9, "USD"))
      end

      it "returns the maximum_charge as Money object scaled as x * (1 - rate)" do
        expect(output_fee.maximum_charge).to eq(Money.from_amount(9000, "USD"))
      end
    end

    context "when the operator is '&' and value is positive" do
      let(:operator) { "&" }
      let(:rate) { 50 }

      it "returns the rate as Money object scaled as x + rate" do
        expect(output_fee.rate).to eq(Money.from_amount(150, "USD"))
      end

      it "returns the minimum_charge as Money object scaled as x + rate" do
        expect(output_fee.minimum_charge).to eq(Money.from_amount(60, "USD"))
      end

      it "returns the maximum_charge as Money object scaled as x + rate" do
        expect(output_fee.maximum_charge).to eq(Money.from_amount(10_050, "USD"))
      end
    end

    context "when the operator is '&' and value is negative" do
      let(:operator) { "&" }
      let(:rate) { -10 }

      it "returns the rate as Money object scaled as x - rate" do
        expect(output_fee.rate).to eq(Money.from_amount(90, "USD"))
      end

      it "returns the minimum_charge as Money object scaled as x - rate" do
        expect(output_fee.minimum_charge).to eq(Money.from_amount(0, "USD"))
      end

      it "returns the maximum_charge as Money object scaled as x - rate" do
        expect(output_fee.maximum_charge).to eq(Money.from_amount(9990, "USD"))
      end
    end

    context "when there is a positive surcharge (aka flat margin)" do
      let(:operator) { "+" }
      let(:rate) { 50 }

      it "leaves the minimum_charge, maximum_charge and rate as is", :aggregate_failures do
        expect(output_fee.rate).to eq(input_fee.rate)
        expect(output_fee.minimum_charge).to eq(input_fee.minimum_charge)
        expect(output_fee.maximum_charge).to eq(input_fee.maximum_charge)
      end

      it "returns the 'flat' margins as Money object under surcharge" do
        expect(output_fee.surcharge).to eq(Money.from_amount(50, "USD"))
      end
    end

    context "when there is a negative surcharge (aka flat margin)" do
      let(:rate) { -50 }
      let(:operator) { "+" }

      it "returns the 'flat' margins as Money object" do
        expect(output_fee.surcharge).to eq(Money.from_amount(-50, "USD"))
      end
    end

    context "when there is a zero surcharge (aka flat margin)" do
      let(:rate) { 0 }
      let(:operator) { "+" }

      it "returns the 'flat' margins as Money object of zero" do
        expect(output_fee.surcharge).to eq(Money.from_amount(0, "USD"))
      end
    end

    context "when there is a zero percentage margin" do
      let(:rate) { 0 }
      let(:operator) { "%" }

      it "returns the rate unadjusted" do
        expect(output_fee.rate).to eq(input_fee.rate)
      end
    end

    context "when there is a zero relative margin" do
      let(:rate) { 0 }
      let(:operator) { "&" }

      it "returns the rate unadjusted" do
        expect(output_fee.rate).to eq(input_fee.rate)
      end
    end

    context "when there is a relative ('&') margin and the rate is a decimal" do
      let(:rate) { 0.05 }
      let(:operator) { "&" }
      let(:fee_rate) { 0.15 }

      it "returns the rate increased by 0.05" do
        expect(output_fee.rate).to eq(fee_rate + rate)
      end
    end
  end
end
