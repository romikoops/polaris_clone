# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Calculator do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  describe "#charges" do
    let(:calculated_charges) { described_class.new(charges: charges).perform }

    context "with a single non percentage fee" do
      let(:charges) do
        [
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: ["aaaa"],
            percentage?: false,
            value: Money.from_amount(10_000, "USD"),
            rate: Money.from_amount(1000, "USD"),
            surcharge: Money.from_amount(0, "USD"))
        ]
      end

      it "returns a single Charge", :aggregate_failures do
        expect(calculated_charges.map(&:value)).to eq([Money.from_amount(10_000, "USD")])
      end
    end

    context "with a percentage fee" do
      let(:charges) do
        [
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: %w[abc aaaa],
            percentage?: false,
            value: Money.from_amount(10_000, "USD"),
            rate: Money.from_amount(1000, "USD"),
            surcharge: Money.from_amount(0, "USD")),
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: %w[abc aaaa],
            percentage?: true,
            value: Money.from_amount(0, "USD"),
            rate: 0.1,
            minimum_charge: Money.from_amount(0, "USD"),
            maximum_charge: Money.from_amount(1_000_000, "USD"),
            surcharge: Money.from_amount(0, "USD"))
        ]
      end

      it "returns two Charges, one based off percentage", :aggregate_failures do
        expect(calculated_charges.map(&:value)).to eq([Money.from_amount(10_000, "USD"), Money.from_amount(10_00, "USD")])
      end
    end

    context "with a percentage fee that include a surcharge" do
      let(:charges) do
        [
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: %w[abc aaaa],
            percentage?: false,
            value: Money.from_amount(10_000, "USD"),
            rate: Money.from_amount(1000, "USD"),
            surcharge: Money.from_amount(0, "USD")),
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: %w[abc aaaa],
            percentage?: true,
            value: Money.from_amount(0, "USD"),
            rate: 0.1,
            minimum_charge: Money.from_amount(0, "USD"),
            maximum_charge: Money.from_amount(1_000_000, "USD"),
            surcharge: Money.from_amount(10, "USD"))
        ]
      end

      it "returns two Charges, one based off percentage with a surcharge added onto the result", :aggregate_failures do
        expect(calculated_charges.map(&:value)).to eq([Money.from_amount(10_000, "USD"), Money.from_amount(10_10, "USD")])
      end
    end

    context "when an ArgumentError is raised by the conversion class" do
      before do
        allow(described_class::PercentageChargeCalculator).to receive(:new).and_raise(ArgumentError)
      end

      let(:charges) do
        [
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: %w[abc aaaa],
            percentage?: false,
            value: Money.from_amount(10_000, "USD"),
            rate: Money.from_amount(1000, "USD"),
            surcharge: Money.from_amount(0, "USD")),
          instance_double(OfferCalculator::Service::Charges::Charge,
            grouping_values: %w[abc aaaa],
            percentage?: true,
            value: Money.from_amount(0, "USD"),
            rate: 0.1,
            minimum_charge: Money.from_amount(0, "USD"),
            maximum_charge: Money.from_amount(1_000_000, "USD"),
            surcharge: Money.from_amount(10, "USD"))
        ]
      end

      it "raises an OfferCalculator::Errors::CalculationError" do
        expect { calculated_charges }.to raise_error(OfferCalculator::Errors::CalculationError)
      end
    end
  end
end
