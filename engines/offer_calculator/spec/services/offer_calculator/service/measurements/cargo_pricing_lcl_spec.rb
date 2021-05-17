# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Cargo do
  let(:organization) { FactoryBot.create(:organizations_organization) }
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
  let(:engine) do
    FactoryBot.create(:measurements_engine_unit,
      scope: scope,
      manipulated_result: manipulated_result,
      cargo_unit: cargo_unit)
  end
  let(:wm_rate) { 2000 }
  let(:vm_rate) { 1 }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization, wm_rate: wm_rate, vm_rate: vm_rate) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json)
  end
  let(:scope) { {} }
  let(:km) { 45.06 }
  let(:measure) do
    described_class.new(
      engine: engine,
      scope: scope.with_indifferent_access,
      object: manipulated_result
    )
  end

  describe ".weight_in_tons" do
    it "returns the weight in tons" do
      aggregate_failures do
        expect(measure.weight_in_tons.value).to eq(1)
        expect(measure.weight_in_tons.unit.name).to eq("t")
      end
    end
  end

  describe ".chargeable_weight_in_tons" do
    it "returns the chargeable weight in tons" do
      aggregate_failures do
        expect(measure.chargeable_weight_in_tons.value).to eq(2)
        expect(measure.chargeable_weight_in_tons.unit.name).to eq("t")
      end
    end
  end

  describe ".chargeable_weight" do
    it "returns the chargeable weight" do
      aggregate_failures do
        expect(measure.chargeable_weight.value).to eq(2000)
        expect(measure.chargeable_weight.unit.name).to eq("kg")
      end
    end
  end

  describe ".unit" do
    it "returns the quantity in units" do
      aggregate_failures do
        expect(measure.unit.value).to eq(1)
        expect(measure.unit.unit.name).to eq("pcs")
      end
    end
  end

  describe ".shipment" do
    it "returns the shipment value in units" do
      aggregate_failures do
        expect(measure.shipment.value).to eq(1)
        expect(measure.shipment.unit.name).to eq("pcs")
      end
    end
  end

  describe ".stackability" do
    it "returns the stackability" do
      expect(measure.stackability).to eq(true)
    end
  end

  describe ".weight_measure" do
    context "with WM_RATE" do
      it "returns the weight_measure " do
        aggregate_failures do
          expect(measure.weight_measure.value).to eq(2)
          expect(measure.weight_measure.unit.name).to eq("t/m3")
        end
      end
    end

    context "with VM_RATE" do
      let(:wm_rate) { 1000 }
      let(:vm_rate) { 0.5 }

      it "returns the weight_measure" do
        aggregate_failures do
          expect(measure.weight_measure.value).to eq(1)
          expect(measure.weight_measure.unit.name).to eq("t/m3")
        end
      end
    end
  end
end
