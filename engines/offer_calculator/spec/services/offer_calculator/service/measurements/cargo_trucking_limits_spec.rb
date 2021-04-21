# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Cargo do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, load_meterage: load_meterage) }
  let(:manipulated_result) { FactoryBot.build(:manipulator_result, original: trucking_pricing, result: trucking_pricing.as_json) }
  let(:scope) { {} }
  let(:stackable) { true }
  let(:cargo_unit) do
    FactoryBot.create(:journey_cargo_unit,
      cargo_class: "lcl",
      weight_value: 1000,
      height_value: 1,
      width_value: 1,
      length_value: 1,
      quantity: 1,
      stackable: stackable)
  end
  let(:measure) do
    described_class.new(
      engine: engine,
      scope: scope.with_indifferent_access,
      object: manipulated_result
    )
  end
  let(:request) do
    FactoryBot.create(:offer_calculator_request)
  end
  let(:engine) do
    FactoryBot.create(:measurements_engines_consolidated,
      scope: scope.with_indifferent_access,
      object: manipulated_result,
      request: request)
  end
  let(:stackable_limit) { nil }
  let(:non_stackable_limit) { nil }
  let(:stackable_type) { nil }
  let(:non_stackable_type) { nil }
  let(:load_meterage) do
    {
      non_stackable_limit: non_stackable_limit,
      stackable_limit: stackable_limit,
      stackable_type: stackable_type,
      non_stackable_type: non_stackable_type,
      hard_limit: true
    }
  end

  before do
    allow(request).to receive(:cargo_units).and_return([cargo_unit])
  end

  describe "with hard limits" do
    shared_examples_for "raising errors when limit is broken" do
      it "raises the LoadMeterageExceeded Error" do
        expect { measure.kg }.to raise_error(OfferCalculator::Errors::LoadMeterageExceeded)
      end
    end

    shared_examples_for "passes the given limits" do
      it "raises the LoadMeterageExceeded Error" do
        expect { measure.kg }.not_to raise_error
      end
    end

    context "with non-stackable area limit and non-stackable goods" do
      let(:non_stackable_type) { "area" }
      let(:non_stackable_limit) { 0.005 }
      let(:stackable) { false }

      it_behaves_like "raising errors when limit is broken"
    end

    context "with non-stackable area limit and stackable goods" do
      let(:non_stackable_type) { "area" }
      let(:non_stackable_limit) { 0.005 }
      let(:stackable) { true }

      it_behaves_like "passes the given limits"
    end

    context "with stackable area limit and non-stackable goods" do
      let(:stackable_type) { "area" }
      let(:stackable_limit) { 0.005 }
      let(:stackable) { false }

      it_behaves_like "passes the given limits"
    end

    context "with stackable area limit and stackable goods" do
      let(:stackable_type) { "area" }
      let(:stackable_limit) { 0.005 }
      let(:stackable) { true }

      it_behaves_like "raising errors when limit is broken"
    end

    context "with stackable volume limit and non-stackable goods" do
      let(:stackable_type) { "volume" }
      let(:stackable_limit) { 0.005 }
      let(:stackable) { false }

      it_behaves_like "passes the given limits"
    end

    context "with stackable volume limit and stackable goods" do
      let(:stackable_type) { "volume" }
      let(:stackable_limit) { 0.005 }
      let(:stackable) { true }

      it_behaves_like "raising errors when limit is broken"
    end

    context "with stackable ldm limit and non-stackable goods" do
      let(:stackable_type) { "ldm" }
      let(:stackable_limit) { 0.005 }
      let(:stackable) { false }

      it_behaves_like "passes the given limits"
    end

    context "with stackable ldm limit and stackable goods" do
      let(:stackable_type) { "ldm" }
      let(:stackable_limit) { 0.005 }
      let(:stackable) { true }

      it_behaves_like "raising errors when limit is broken"
    end
  end
end
