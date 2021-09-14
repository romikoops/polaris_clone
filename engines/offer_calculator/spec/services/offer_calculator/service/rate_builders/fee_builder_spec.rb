# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::FeeBuilder do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:charge_category) { pricing.fees.first.charge_category }
  let(:margin) do
    FactoryBot.create(:pricings_margin,
      organization: organization,
      tenant_vehicle_id: pricing.tenant_vehicle_id,
      applicable: organization)
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:cargo_unit) do
    FactoryBot.create(:journey_cargo_unit,
      cargo_class: "lcl",
      weight_value: 1000,
      height_value: 1,
      width_value: 1,
      length_value: 1,
      quantity: 1,
      stackable: true)
  end
  let(:scope) { {} }
  let(:engine) do
    FactoryBot.create(:measurements_engine_unit,
      scope: scope,
      manipulated_result: manipulated_result,
      cargo_unit: cargo_unit)
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Cargo.new(
      engine: engine,
      scope: {},
      object: manipulated_result
    )
  end
  let(:max_value) { Money.new(OfferCalculator::Service::RateBuilders::Base::DEFAULT_MAX * 100, input_fee["currency"]) }
  let(:min_value) { Money.new(input_fee["min"] * 100.0, input_fee["currency"]) }

  describe "it creates a valid FeeComponent object" do
    let(:fee) do
      described_class.fee(
        request: request,
        fee: input_fee,
        code: input_fee["key"] || pricing_fee.charge_category.code,
        measures: measures
      )
    end

    shared_examples_for "building a valid Fee" do
      it "sets all the correct info on the fee", :aggregate_failures do
        expect(fee).to  be_a(OfferCalculator::Service::RateBuilders::Fee)
        expect(fee.rate_basis).to eq(input_fee["rate_basis"])
        expect(fee.min_value).to eq(min_value)
        expect(fee.max_value).to eq(max_value)
      end
    end

    context "with Pricings::Fee" do
      let(:input_fee) { pricing_fee.fee_data.as_json }
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm, pricing: pricing) }
      let(:min_value) { Money.new(pricing_fee.min * 100.0, input_fee["currency"]) }

      it_behaves_like "building a valid Fee"
    end

    context "with LocalCharge fee" do
      let(:input_fee) { FactoryBot.build(:component_builder_fee, :ton) }

      it_behaves_like "building a valid Fee"
    end

    context "with minimum and maximum keys" do
      let(:input_fee) { FactoryBot.build(:component_builder_fee, :maximum_minimum) }
      let(:min_value) { Money.new(input_fee["minimum"] * 100.0, input_fee["currency"]) }
      let(:max_value) { Money.new(input_fee["maximum"] * 100.0, input_fee["currency"]) }

      it_behaves_like "building a valid Fee"
    end
  end
end
