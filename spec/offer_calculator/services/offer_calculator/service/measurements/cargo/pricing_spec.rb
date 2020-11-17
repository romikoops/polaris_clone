# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Cargo do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:cargo) do
    FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
      FactoryBot.create(:lcl_unit,
        cargo: tapped_cargo,
        weight_value: 1000,
        height_value: 1,
        width_value: 1,
        length_value: 1,
        stackable: true)
    end
  end
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization, wm_rate: 2000) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:scope) { {} }
  let(:km) { 45.06 }
  let(:target_cargo) { cargo }
  let(:measure) do
    described_class.new(
      cargo: target_cargo,
      scope: scope.with_indifferent_access,
      object: manipulated_result
    )
  end

  context "when asking for measurement values" do
    it "returns the weight in tons" do
      aggregate_failures do
        expect(measure.weight_in_tons.value).to eq(1)
        expect(measure.weight_in_tons.unit.name).to eq("t")
      end
    end

    it "returns the chargeable weight in tons" do
      aggregate_failures do
        expect(measure.chargeable_weight_in_tons.value).to eq(2)
        expect(measure.chargeable_weight_in_tons.unit.name).to eq("t")
      end
    end

    it "returns the chargeable weight" do
      aggregate_failures do
        expect(measure.chargeable_weight.value).to eq(2000)
        expect(measure.chargeable_weight.unit.name).to eq("kg")
      end
    end

    it "returns the quantity in units" do
      aggregate_failures do
        expect(measure.unit.value).to eq(1)
        expect(measure.unit.unit.name).to eq("pcs")
      end
    end

    it "returns the shipment value in units" do
      aggregate_failures do
        expect(measure.shipment.value).to eq(1)
        expect(measure.shipment.unit.name).to eq("pcs")
      end
    end

    it "returns the stackability" do
      expect(measure.stackability).to eq(true)
    end

    it "returns the weight_measure" do
      aggregate_failures do
        expect(measure.weight_measure.value).to eq(2)
        expect(measure.weight_measure.unit.name).to eq("t/m3")
      end
    end
  end

  describe ".units" do
    context "with no consolidation" do
      let(:target_cargo) { cargo }
      let(:children) { measure.children }

      it "returns the children for the object cargo class" do
        aggregate_failures do
          expect(children.length).to eq(1)
          expect(children.first).to be_a(OfferCalculator::Service::Measurements::Unit)
          expect(children.first.cargo).to eq(cargo.units.first)
        end
      end
    end

    context "with consolidation" do
      let(:target_cargo) { cargo }
      let(:children) { measure.children }
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the children for the object cargo class" do
        aggregate_failures do
          expect(children.length).to eq(1)
          expect(children.first).to be_a(OfferCalculator::Service::Measurements::Consolidated)
          expect(children.first.cargo).to eq(cargo)
        end
      end
    end

    context "with consolidation && fcl" do
      let(:target_cargo) do
        FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
          FactoryBot.create(:fcl_20_unit,
            cargo: tapped_cargo,
            weight_value: 1000,
            stackable: true)
        end
      end
      let(:pricing) { FactoryBot.create(:fcl_20_pricing, organization: organization, wm_rate: 2000) }
      let(:children) { measure.children }
      let(:scope) { {consolidation: {cargo: {backend: true}}} }

      it "returns the children for the object cargo class" do
        aggregate_failures do
          expect(children.length).to eq(1)
          expect(children.first).to be_a(OfferCalculator::Service::Measurements::Unit)
          expect(children.first.cargo).to eq(target_cargo.units.first)
        end
      end

      it "returns the total weight" do
        aggregate_failures do
          expect(measure.chargeable_weight.value).to eq(2000)
          expect(measure.chargeable_weight.unit.name).to eq("kg")
        end
      end
    end
  end
end
