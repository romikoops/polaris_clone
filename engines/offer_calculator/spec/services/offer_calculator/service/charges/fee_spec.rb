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
      range_min: range_min,
      range_max: range_max,
      measure: 1,
      range_unit: range_unit,
      sourced_from_margin: sourced_from_margin
    )
  end
  let(:range_unit) { "shipment" }
  let(:rate_basis) { "PER_SHIPMENT" }
  let(:sourced_from_margin) { false }
  let(:rate_of_charge) { Money.from_amount(100, currency) }
  let(:currency) { Money::Currency.new("USD") }
  let(:range_min) { 0 }
  let(:range_max) { Float::INFINITY }

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

  describe "#legacy_format" do
    let(:expected_format) do
      {
        rate: rate_of_charge.amount,
        base: 0,
        rate_basis: rate_basis,
        currency: currency.iso_code,
        min: 10,
        max: 10_000,
        range: []
      }
    end

    it "returns a hash with the legacy format" do
      expect(fee.legacy_format).to eq(expected_format)
    end

    context "when it is a trucking fee" do
      let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization, code: "trucking_lcl") }
      let(:range_unit) { "kg" }
      let(:expected_format) do
        {
          range_unit => [
            {
              "rate" => {
                "rate" => rate_of_charge.amount,
                "base" => 0,
                "rate_basis" => rate_basis,
                "currency" => currency.iso_code
              },
              "min_value" => 10,
              "max_value" => 10_000,
              "min_#{range_unit}" => range_min,
              "max_#{range_unit}" => range_max
            }
          ]
        }
      end
      let(:range_min) { 0 }
      let(:range_max) { 100 }

      it "returns a hash with the legacy format" do
        expect(fee.legacy_format).to eq(expected_format)
      end
    end

    context "when it is a ranged fee" do
      let(:range_unit) { "kg" }
      let(:expected_format) do
        {
          rate: rate_of_charge.amount,
          base: 0,
          rate_basis: rate_basis,
          currency: currency.iso_code,
          min: 10,
          max: 10_000,
          range: [
            {
              rate: rate_of_charge.amount,
              base: 0,
              rate_basis: rate_basis,
              currency: currency.iso_code,
              min: range_min,
              max: range_max
            }
          ]
        }
      end
      let(:range_min) { 0 }
      let(:range_max) { 100 }

      it "returns a hash with the legacy format" do
        expect(fee.legacy_format).to eq(expected_format)
      end
    end

    context "when the rate_basis is PERCENTAGE" do
      let(:rate_basis) { "PERCENTAGE" }
      let(:expected_format) do
        {
          rate: rate_of_charge,
          base: 0,
          rate_basis: rate_basis,
          currency: currency.iso_code,
          min: 10,
          max: 10_000,
          range: []
        }
      end
      let(:rate_of_charge) { 0.09 }

      it "returns a hash with the legacy format" do
        expect(fee.legacy_format).to eq(expected_format)
      end
    end
  end
end
