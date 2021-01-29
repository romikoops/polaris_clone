# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Truckings do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:measures) do
    OfferCalculator::Service::Measurements::Request.new(
      request: request,
      scope: scope.with_indifferent_access,
      object: object
    )
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:cbm_ratio) { 250 }
  let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, organization: organization, cbm_ratio: cbm_ratio) }
  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, organization: organization) }
  let!(:trucking_lcl_charge_category) {
    FactoryBot.create(:legacy_charge_categories, organization: organization, code: "trucking_lcl")
  }
  let(:puf_original_fee) { trucking_pricing.fees["PUF"] }
  let(:trucking_original_fee) { trucking_pricing.rates.dig("kg", 0, "rate") }
  let(:scope) { {} }
  let(:breakdowns) do
    breakdown_array = []
    trucking_pricing.fees.each do |key, fee|
      breakdown_array << Pricings::ManipulatorBreakdown.new(
        source: nil,
        delta: 0,
        data: fee,
        charge_category: Legacy::ChargeCategory.from_code(organization_id: organization.id, code: key)
      )
    end
    breakdown_array << Pricings::ManipulatorBreakdown.new(
      source: nil,
      delta: 0,
      data: trucking_pricing.rates,
      charge_category: trucking_lcl_charge_category
    )
    breakdown_array
  end
  let(:object) {
    FactoryBot.build(:manipulator_result,
      original: trucking_pricing, result: trucking_pricing.as_json, breakdowns: breakdowns)
  }
  let(:puf_fee) { results.find { |f| f.charge_category == puf_charge_category } }
  let(:trucking_fee) { results.find { |f| f.charge_category == trucking_lcl_charge_category } }
  let(:puf_component) { puf_fee.components.first }
  let(:trucking_component) { trucking_fee.components.first }
  let(:cargo_units) do
    [FactoryBot.create(:journey_cargo_unit,
      width_value: 1.20,
      length_value: 0.80,
      height_value: 1.40,
      weight_value: 500,
      quantity: 1)]
  end

  before do
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  describe ".perform" do
    context "with freight pricing (no consolidation)" do
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(puf_fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
          expect(results.map(&:charge_category)).to match_array([puf_charge_category, trucking_lcl_charge_category])
        end
      end

      it "returns the correct fee components (trucking fees)" do
        aggregate_failures do
          expect(puf_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(puf_fee.components.length).to eq(1)
          expect(puf_component.value).to eq(Money.new(puf_original_fee["value"] * 100, puf_original_fee["currency"]))
        end
      end

      it "returns the correct fee components (trucking rate)" do
        aggregate_failures do
          expect(trucking_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(trucking_fee.components.length).to eq(1)
          expect(
            trucking_component.value
          ).to eq(Money.new(trucking_original_fee["value"] * 100, trucking_original_fee["currency"]))
        end
      end
    end

    context "with hard trucking limit" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.40,
          weight_value: 100_000,
          quantity: 1)]
      end
      let(:scope) { {hard_trucking_limit: true} }
      let(:errors) { described_class.fees(request: request, measures: measures) }
      let(:journey_error) { Journey::Error.find_by(code: OfferCalculator::Errors::LoadMeterageExceeded.new.code) }

      it "creates a Journey::Error and raises and error when above the limit" do
        expect { errors }.to raise_error(OfferCalculator::Errors::LoadMeterageExceeded)
        expect(journey_error).to be_present
      end
    end

    context "with hard trucking limit and multiple ranges (one above range)" do
      let(:trucking_pricing) {
        FactoryBot.create(:trucking_trucking, :unit_and_kg, organization: organization, cbm_ratio: cbm_ratio, fees: {})
      }
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 2100,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.40,
          quantity: 1)]
      end
      let(:scope) { {hard_trucking_limit: true}.with_indifferent_access }

      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns fees as one range is valid" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(trucking_fee.components.length).to eq(1)
        end
      end
    end

    context "without hard trucking limit" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 100_000,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.40,
          quantity: 1)]
      end
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
          expect(results.map(&:charge_category)).to match_array([puf_charge_category, trucking_lcl_charge_category])
        end
      end
    end

    context "when below range" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 0.001,
          height_value: 0.001,
          width_value: 0.001,
          length_value: 0.001,
          quantity: 1)]
      end
      let(:cbm_ratio) { 1 }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end

    context "with unit_in_kg fees" do
      let(:trucking_pricing) { FactoryBot.create(:trucking_with_unit_and_kg, organization: organization) }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end

    context "with wm fees" do
      let(:trucking_pricing) { FactoryBot.create(:trucking_with_wm_rates, organization: organization) }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end

    context "with fcl_20 cargo" do
      let(:trucking_pricing) { FactoryBot.create(:fcl_20_unit_trucking, organization: organization) }
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          cargo_class: "fcl_20",
          quantity: 2)]
      end
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end
  end
end
