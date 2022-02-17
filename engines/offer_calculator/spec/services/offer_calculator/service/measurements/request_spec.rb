# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Request do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:query) {
    FactoryBot.build(:journey_query,
      organization: organization,
      cargo_count: 0,
      load_type: cargo_trait)
  }
  let(:request) { FactoryBot.create(:offer_calculator_request, query: query, cargo_trait: cargo_trait) }
  let(:cargo_trait) { :lcl }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization, wm_rate: 2000) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:scope) { {} }
  let(:km) { 45.06 }
  let(:measure) do
    described_class.new(
      request: request,
      scope: scope.with_indifferent_access,
      object: manipulated_result
    )
  end
  let(:cargo_units) { request.cargo_units }

  describe ".targets" do
    let(:targets) { measure.targets }

    context "with no consolidation" do
      it "returns the targets for the object cargo class" do
        aggregate_failures do
          expect(targets.length).to eq(1)
          expect(targets.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Unit)
          expect(targets.first.cargo_units).to eq([cargo_units.first])
        end
      end
    end

    context "with consolidation" do
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the targets for the object cargo class" do
        aggregate_failures do
          expect(targets.length).to eq(1)
          expect(targets.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Consolidated)
          expect(targets.first.cargo_units).to eq(cargo_units)
        end
      end
    end

    context "with consolidation && fcl" do
      let(:cargo_trait) { :fcl }
      let(:pricing) { FactoryBot.create(:fcl_20_pricing, organization: organization, wm_rate: 2000) }
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the targets for the object cargo class" do
        aggregate_failures do
          expect(targets.length).to eq(1)
          expect(targets.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Unit)
          expect(targets.first.cargo_units).to eq([cargo_units.first])
        end
      end
    end
  end

  describe ".validation_targets" do
    let(:targets) { measure.validation_targets }

    context "with consolidation" do
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the targets for the each cargo unit" do
        aggregate_failures do
          expect(targets.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Unit)
          expect(targets.flat_map(&:cargo_units)).to match_array(cargo_units)
        end
      end
    end
  end
end
