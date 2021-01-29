# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Request do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:request) { FactoryBot.create(:offer_calculator_request, cargo_trait: cargo_trait) }
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
    let(:children) { measure.targets }

    context "with no consolidation" do
      it "returns the children for the object cargo class" do
        aggregate_failures do
          expect(children.length).to eq(1)
          expect(children.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Unit)
          expect(children.first.cargo_units).to eq([cargo_units.first])
        end
      end
    end

    context "with consolidation" do
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the children for the object cargo class" do
        aggregate_failures do
          expect(children.length).to eq(1)
          expect(children.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Consolidated)
          expect(children.first.cargo_units).to eq(cargo_units)
        end
      end
    end

    context "with consolidation && fcl" do
      let(:cargo_trait) { :fcl }
      let(:pricing) { FactoryBot.create(:fcl_20_pricing, organization: organization, wm_rate: 2000) }
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the children for the object cargo class" do
        aggregate_failures do
          expect(children.length).to eq(1)
          expect(children.first.engine).to be_a(OfferCalculator::Service::Measurements::Engines::Unit)
          expect(children.first.cargo_units).to eq([cargo_units.first])
        end
      end
    end
  end
end
