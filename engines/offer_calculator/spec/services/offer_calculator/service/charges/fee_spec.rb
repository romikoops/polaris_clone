# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Fee do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization) }
  let(:fee) do
    described_class.new(
      rate: rate_of_charge,
      cargo_class: "lcl",
      charge_category_id: charge_category.id,
      rate_basis: rate_basis,
      base: 0,
      minimum_charge: Money.from_amount(10, currency),
      maximum_charge: Money.from_amount(10_000, currency),
      range_min: 0,
      range_max: Float::INFINITY,
      measure: 1,
      sourced_from_margin: sourced_from_margin
    )
  end
  let(:rate_basis) { "PER_SHIPMENT" }
  let(:sourced_from_margin) { false }
  let(:rate_of_charge) { Money.from_amount(100, currency) }
  let(:currency) { Money::Currency.new("USD") }

  describe "#charge_category" do
    it "returns the ChargeCategory based on the id" do
      expect(fee.charge_category).to eq(charge_category)
    end
  end

  describe "#sourced_from_margin?" do
    context "when 'sourced_from_margin' is false" do
      it "returns false" do
        expect(fee).not_to be_sourced_from_margin
      end
    end

    context "when 'sourced_from_margin' is true" do
      let(:sourced_from_margin) { true }

      it "returns true" do
        expect(fee).to be_sourced_from_margin
      end
    end
  end

  describe "#percentage?" do
    context "when the rate_basis is not PERCENTAGE" do
      it "returns false" do
        expect(fee).not_to be_percentage
      end
    end

    context "when the rate_basis is PERCENTAGE" do
      let(:rate_basis) { "PERCENTAGE" }

      it "returns true" do
        expect(fee).to be_percentage
      end
    end
  end
end
