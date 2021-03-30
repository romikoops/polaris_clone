# frozen_string_literal: true

require "rails_helper"
RSpec.shared_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL" do
  it "returns the regular values regardless of load meterage configuration", :aggregate_failures do
    expect(measure.kg.value).to eq(cargo_units.first.weight_value)
    expect(measure.kg.unit.name).to eq("kg")
    expect(measure.stackability).to eq(true)
  end

  it "calculates the correct area" do
    aggregate_failures do
      expect(measure.area_for_load_meters).to eq(0.96)
    end
  end
end

RSpec.describe OfferCalculator::Service::Measurements::Cargo do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  let(:trucking_location) { FactoryBot.create(:trucking_location, :distance, data: distance) }
  let(:distance) { 15 }
  let(:trucking_pricing) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      load_meterage: load_meterage,
      cbm_ratio: cbm_ratio,
      location: trucking_location)
  end
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: trucking_pricing,
      result: trucking_pricing.as_json)
  end
  let(:scope) { {} }
  let(:target_cargo) { cargo }
  let(:cbm_ratio) { 250 }
  let(:load_meterage) { {} }
  let(:cargo_units) do
    [FactoryBot.create(:journey_cargo_unit,
      cargo_class: "aggregated_lcl",
      weight_value: 1000,
      volume_value: 1,
      quantity: 1,
      stackable: true)]
  end
  let(:engine) do
    FactoryBot.create(:measurements_engine_unit,
      scope: scope,
      manipulated_result: manipulated_result,
      cargo_unit: cargo_unit)
  end
  let(:measure) do
    described_class.new(
      engine: engine,
      scope: scope.with_indifferent_access,
      object: manipulated_result
    )
  end

  describe "when asking for chargeable weight" do
    context "without load_meterage" do
      let(:cargo_unit) do
        FactoryBot.create(:journey_cargo_unit,
          cargo_class: "aggregated_lcl",
          weight_value: 1000,
          volume_value: 1,
          quantity: 1,
          stackable: true)
      end

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end
  end

  describe "when consolidated" do
    let(:request) do
      FactoryBot.create(:offer_calculator_request)
    end
    let(:engine) do
      FactoryBot.create(:measurements_engines_consolidated,
        scope: scope.with_indifferent_access,
        object: manipulated_result,
        request: request)
    end

    before do
      allow(request).to receive(:cargo_units).and_return(cargo_units)
    end

    context "with scope consolidation.trucking.calculation" do
      let(:scope) { { consolidation: { trucking: { calculation: true } } } }

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end

    context "with  scope consolidation.trucking.comparative" do
      let(:scope) { { 'consolidation': { 'trucking': { 'comparative': true } } } }
      let(:load_meterage) { { ratio: 1000, ldm_limit: 48_000, stacking: false } }
      let(:cbm_ratio) { 200 }

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end

    context "with scope consolidation.trucking.comparative (non-stackable)" do
      let(:scope) { { 'consolidation': { 'trucking': { 'comparative': true } } } }
      let(:load_meterage) { { ratio: 1000, lm_limit: 0.5 } }
      let(:cbm_ratio) { 200 }

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end

    context "with scope consolidation.trucking.calculation with agg cargo" do
      let(:scope) { { 'consolidation': { 'trucking': { 'calculation': true } } } }
      let(:load_meterage) { { ratio: 1000, lm_limit: 0.5 } }
      let(:cbm_ratio) { 250 }

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end

    context "with scope consolidation.trucking.load_meterage_only" do
      let(:scope) { { 'consolidation': { 'trucking': { 'load_meterage_only': true } } } }
      let(:cbm_ratio) { 250 }

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end

    context "with consolidation.trucking.load_meterage_only (low limit)" do
      let(:scope) { { 'consolidation': { 'trucking': { 'load_meterage_only': true } } } }
      let(:load_meterage) { { area_limit: 0.5, ratio: 1000 } }
      let(:cbm_ratio) { 250 }

      include_examples "OfferCalculator::Service::Measurements::Cargo Agg LCL"
    end

    context "with hard load meterage limit" do
      let(:scope) { { 'consolidation': { 'trucking': { 'load_meterage_only': true } } } }
      let(:load_meterage) { { area_limit: 0.005, ratio: 1000, hard_limit: true } }
      let(:cargo_unit) do
        FactoryBot.create(:journey_cargo_unit,
          cargo_class: "aggregated_lcl",
          weight_value: 50_000,
          volume_value: 1,
          quantity: 1,
          stackable: true)
      end

      it "returns the correct weight" do
        expect { measure.kg }.to raise_error(OfferCalculator::Errors::LoadMeterageExceeded)
      end
    end
  end
end
