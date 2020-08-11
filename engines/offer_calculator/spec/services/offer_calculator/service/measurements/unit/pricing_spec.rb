# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Unit do
  let(:min_value) { Money.new(1000, "USD") }
  let(:rate_basis) { "PER_WM" }
  let(:target) { nil }
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
  let(:target_cargo) { cargo.units.first }
  let(:measure) do
    described_class.new(
      cargo: target_cargo,
      scope: scope,
      object: manipulated_result,
      km: km
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
end
