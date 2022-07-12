# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Cargo do
  let(:min_value) { Money.new(1000, "USD") }
  let(:rate_basis) { "PER_WM" }
  let(:target) { nil }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:cargo_unit) do
    FactoryBot.create(:journey_cargo_unit,
      cargo_class: "aggregated_lcl",
      weight_value: 1000,
      volume_value: 2,
      quantity: 1,
      stackable: true)
  end
  let(:engine) do
    FactoryBot.create(:measurements_engine_unit,
      scope: scope,
      manipulated_result: manipulated_result,
      cargo_unit: cargo_unit)
  end
  let(:local_charge) { FactoryBot.create(:legacy_local_charge, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: local_charge,
      result: local_charge.as_json)
  end
  let(:scope) { {} }
  let(:measure) do
    described_class.new(
      engine: engine,
      scope: scope,
      object: manipulated_result
    )
  end

  context "when asking for measurement values" do
    it "returns the fallback km vlaue" do
      aggregate_failures do
        expect(measure.km.value).to eq(0)
        expect(measure.km.unit.name).to eq("km")
      end
    end

    it "returns the weight in tons" do
      aggregate_failures do
        expect(measure.weight_in_tons.value).to eq(1)
        expect(measure.weight_in_tons.unit.name).to eq("t")
      end
    end

    it "returns the chargeable weight in tons" do
      aggregate_failures do
        expect(measure.chargeable_weight_in_tons.value).to eq(1)
        expect(measure.chargeable_weight_in_tons.unit.name).to eq("t")
      end
    end

    it "returns the chargeable weight" do
      aggregate_failures do
        expect(measure.chargeable_weight.value).to eq(1000)
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

    it "returns bill as shipment" do
      expect(measure.bill).to eq(measure.shipment)
    end

    it "returns container as unit" do
      expect(measure.container).to eq(measure.unit)
    end
  end
end
