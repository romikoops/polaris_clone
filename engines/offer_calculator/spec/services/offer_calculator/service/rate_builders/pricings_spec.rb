# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Pricings do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:measures) do
    OfferCalculator::Service::Measurements::Request.new(
      request: request,
      scope: scope.with_indifferent_access,
      object: object
    )
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, organization: organization) }
  let(:bas_charge_category) { FactoryBot.create(:bas_charge, organization: organization) }
  let(:bas_fee) { pricing.fees.find_by(charge_category: bas_charge_category) }
  let(:scope) { organization.scope.content }
  let(:breakdowns) do
    pricing.fees.map do |fee|
      Pricings::ManipulatorBreakdown.new(
        source: nil,
        delta: 0,
        data: fee.fee_data,
        charge_category: fee.charge_category
      )
    end
  end
  let(:object) {
    FactoryBot.build(:manipulator_result, original: pricing, result: pricing.as_json, breakdowns: breakdowns)
  }
  let(:cargo_units) do
    [FactoryBot.create(:journey_cargo_unit,
      weight_value: 200,
      width_value: 0.2,
      length_value: 0.2,
      height_value: 0.2,
      quantity: 1)]
  end

  before do
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  describe ".perform" do
    context "with freight pricing (no consolidation)" do
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(1)
          expect(fee.charge_category).to eq(bas_charge_category)
        end
      end

      it "returns the correct fee components" do
        aggregate_failures do
          expect(component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(fee.components.length).to eq(1)
          expect(component.value).to eq(Money.new(bas_fee.rate * 100, bas_fee.currency_name))
        end
      end
    end

    context "with freight pricing (multiple fees & no consolidation)" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 200,
          width_value: 0.2,
          length_value: 0.2,
          height_value: 0.2,
          quantity: 1)]
      end
      let(:bas_fee_result) { results.find { |f| f.charge_category == bas_charge_category } }
      let(:baf_fee_result) { results.find { |f| f.charge_category == baf_charge_category } }
      let(:first_component) { bas_fee_result.components.first }
      let(:second_component) { baf_fee_result.components.first }
      let!(:baf_fee) { FactoryBot.create(:fee_per_wm, charge_category: baf_charge_category, pricing: pricing) }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(bas_fee_result).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
          expect(bas_fee_result.charge_category).to eq(bas_charge_category)
        end
      end

      it "returns the correct fee components (first)" do
        aggregate_failures do
          expect(first_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(bas_fee_result.components.length).to eq(1)
          expect(first_component.value).to eq(Money.new(bas_fee.rate * 100, bas_fee.currency_name))
        end
      end

      it "returns the correct fee components (second)" do
        aggregate_failures do
          expect(second_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(baf_fee_result.components.length).to eq(1)
          expect(second_component.value).to eq(Money.new(baf_fee.rate * 100, baf_fee.currency_name))
        end
      end
    end

    context "with freight pricing (consolidation)" do
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let(:scope) { {consolidation: {cargo: {backend: true}}}.with_indifferent_access }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(1)
          expect(fee.charge_category).to eq(pricing.fees.first.charge_category)
          expect(fee.targets).to eq(cargo_units)
        end
      end

      it "returns the correct fee components" do
        aggregate_failures do
          expect(component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(fee.components.length).to eq(1)
          expect(component.value).to eq(Money.new(pricing.fees.first.rate * 100, pricing.fees.first.currency_name))
        end
      end
    end

    context "with freight pricing (ranges)" do
      let(:pricing) { FactoryBot.create(:lcl_range_pricing, organization: organization) }
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(1)
          expect(fee.charge_category).to eq(pricing.fees.first.charge_category)
        end
      end

      it "returns the correct fee components" do
        aggregate_failures do
          expect(component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(fee.components.length).to eq(1)
          target_range = pricing.fees.first.range.find { |range|
            (range["min"]..range["max"]).cover?(measures.targets.first.kg.value)
          }
          expect(component.value).to eq(Money.new(target_range["rate"] * 100, pricing.fees.first.currency_name))
        end
      end
    end

    context "with freight pricing (ranges & multiple cargos)" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 200,
          width_value: 0.2,
          length_value: 0.2,
          height_value: 0.2,
          quantity: 1),
          FactoryBot.create(:journey_cargo_unit,
            weight_value: 100,
            width_value: 0.2,
            length_value: 0.2,
            height_value: 0.2,
            quantity: 1)]
      end
      let(:pricing) { FactoryBot.create(:lcl_range_pricing, organization: organization) }
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
          expect(results.flat_map(&:targets)).to eq(cargo_units)
        end
      end
    end

    context "with freight pricing (per shipment fee & multiple cargos)" do
      before do
        FactoryBot.create(:fee_per_shipment, charge_category: baf_charge_category, pricing: pricing)
      end

      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 200,
          width_value: 0.2,
          length_value: 0.2,
          height_value: 0.2,
          quantity: 1),
          FactoryBot.create(:journey_cargo_unit,
            weight_value: 100,
            width_value: 0.2,
            length_value: 0.2,
            height_value: 0.2,
            quantity: 1)]
      end
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(4)
          expect(results.flat_map(&:targets)).to match_array(cargo_units)
          expect(results.count { |result| result.charge_category == baf_charge_category }).to eq(2)
        end
      end
    end
  end
end
