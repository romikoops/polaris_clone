# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::RangeFinder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:range_finder) { described_class.new(fees: Rover::DataFrame.new(fees), margins: Rover::DataFrame.new(margins), measure: measure, scope: scope) }
  let(:charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization) }
  let(:scope) { {} }
  let(:margins) do
    { "id" => [],
      "rate" => [],
      "operator" => [],
      "code" => [],
      "margin_id" => [],
      "applicable_id" => [],
      "applicable_type" => [],
      "effective_date" => [],
      "expiration_date" => [],
      "origin_hub_id" => [],
      "destination_hub_id" => [],
      "tenant_vehicle_id" => [],
      "pricing_id" => [],
      "cargo_class" => [],
      "margin_type" => [],
      "rank" => [] }
  end

  before { Organizations.current_id = organization.id }

  context "when the fee rows are present" do
    let(:fees) do
      [
        {
          "rate" => 100.0,
          "currency" => "USD",
          "charge_category_id" => charge_category.id,
          "rate_basis" => "PER_SHIPMENT",
          "base" => nil,
          "min" => 0,
          "max" => 10_000,
          "range_min" => 0,
          "range_max" => Float::INFINITY,
          "range_unit" => "shipment"
        }
      ]
    end
    let(:measure) { 1 }

    describe "#fee" do
      context "without ranges (one fee with range 0 - INFINITY)" do
        it "returns the correct fee row" do
          expect(range_finder.fee).to be_present
        end

        it "returns the correct fee row with a MoneyRate" do
          expect(range_finder.fee.rate).to eq(Money.from_amount(fees.first["rate"], fees.first["currency"]))
        end
      end

      context "with a PERCENTAGE rate_basis" do
        let(:fees) do
          [
            {
              "rate" => 0.1,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PERCENTAGE",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 0,
              "range_max" => Float::INFINITY,
              "range_unit" => "percentage"
            }
          ]
        end

        it "returns the correct fee row with a PercentageRate" do
          expect(range_finder.fee.rate).to eq(fees.first["rate"])
        end
      end

      context "with ranges and fee is found" do
        let(:fees) do
          [
            {
              "rate" => 100.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 0,
              "range_max" => 1000,
              "range_unit" => "kg"
            },
            {
              "rate" => 150.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 1000,
              "range_max" => 2000,
              "range_unit" => "kg"
            }
          ]
        end
        let(:measure) { 1500.0 }

        it "returns the correct fee row" do
          expect(range_finder.fee.rate).to eq(Money.from_amount(fees.last["rate"], fees.first["currency"]))
        end
      end

      context "when the measure lies within the fees range as a whole, and misses the individual ranges" do
        let(:measure) { 1020.0 }
        let(:fees) do
          [
            {
              "rate" => 100.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 0,
              "range_max" => 1000,
              "range_unit" => "kg"
            },
            {
              "rate" => 150.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 1050,
              "range_max" => 2000,
              "range_unit" => "kg"
            }
          ]
        end

        it "raises the missing range error" do
          expect { range_finder.fee }.to raise_error(OfferCalculator::Errors::MissedInRange)
        end
      end

      context "when the measure lies beyond the fees range as a whole and 'hard_trucking_limit' is set to true" do
        let(:measure) { 2020.0 }
        let(:scope) { { "hard_trucking_limit" => true } }
        let(:fees) do
          [
            {
              "rate" => 100.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 0,
              "range_max" => 1000,
              "range_unit" => "kg"
            }
          ]
        end

        it "raises the exceeded range error" do
          expect { range_finder.fee }.to raise_error(OfferCalculator::Errors::ExceededRange)
        end
      end

      context "when the measure lies beyond the fees range as a whole and 'hard_trucking_limit' is set to false" do
        let(:measure) { 2020.0 }
        let(:scope) { { "hard_trucking_limit" => false } }
        let(:fees) do
          [
            {
              "rate" => 100.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 0,
              "range_max" => 1000,
              "range_unit" => "kg"
            }, {
              "rate" => 150.0,
              "currency" => "USD",
              "charge_category_id" => charge_category.id,
              "rate_basis" => "PER_SHIPMENT",
              "base" => nil,
              "min" => 0,
              "max" => 10_000,
              "range_min" => 1050,
              "range_max" => 2000,
              "range_unit" => "kg"
            }
          ]
        end

        it "returns the fee row with the highest range_max as the rate" do
          expect(range_finder.fee.range_max).to eq(2000)
        end
      end
    end

    describe "#range_unit" do
      it "returns true when there are only margin rows" do
        expect(range_finder.range_unit).to eq("shipment")
      end
    end
  end

  context "with no fees but a margin" do
    let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
    let(:margins) do
      Rover::DataFrame.new([{
        "id" => margin.id,
        "rate" => 50,
        "operator" => "&",
        "code" => "bas",
        "margin_id" => margin.id,
        "applicable_id" => margin.applicable_id,
        "applicable_type" => margin.applicable_type,
        "effective_date" => margin.effective_date,
        "expiration_date" => margin.expiration_date,
        "origin_hub_id" => margin.origin_hub_id,
        "destination_hub_id" => margin.destination_hub_id,
        "tenant_vehicle_id" => margin.tenant_vehicle_id,
        "pricing_id" => margin.pricing_id,
        "cargo_class" => "lcl",
        "margin_type" => "freight_margin",
        "range_min" => 0,
        "range_max" => Float::INFINITY,
        "range_unit" => "unit",
        "currency" => "USD",
        "rank" => 1
      }])
    end
    let(:fees) do
      {
        "rate" => [],
        "currency" => [],
        "charge_category_id" => [],
        "rate_basis" => [],
        "base" => [],
        "min" => [],
        "max" => [],
        "range_min" => [],
        "range_max" => [],
        "range_unit" => []
      }
    end
    let(:measure) { 2.0 }

    describe "#fee" do
      it "returns the rate based off the margin" do
        expect(range_finder.fee.rate).to eq(Money.from_amount(50, "USD"))
      end
    end

    describe "#range_unit" do
      it "returns true when there are only margin rows" do
        expect(range_finder.range_unit).to eq("unit")
      end
    end
  end

  context "with no fees and no margins" do
    let(:fees) do
      {
        "rate" => [],
        "currency" => [],
        "charge_category_id" => [],
        "rate_basis" => [],
        "base" => [],
        "min" => [],
        "max" => [],
        "range_min" => [],
        "range_max" => [],
        "range_unit" => []
      }
    end
    let(:measure) { 2.0 }

    describe "#fee" do
      it "raises an ArgumentError" do
        expect { range_finder.fee }.to raise_error(/Either fees or margins are required./)
      end
    end
  end
end
