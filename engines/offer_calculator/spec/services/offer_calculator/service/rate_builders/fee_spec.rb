# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Fee do
  let(:min_value) { Money.new(1000, "USD") }
  let(:max_value) { Money.new(1e9, "USD") }
  let(:rate_basis) { "PER_WM" }
  let(:target) { nil }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:charge_category) { pricing.fees.first.charge_category }
  let(:margin) do
    FactoryBot.create(:pricings_margin,
      organization: organization,
      tenant_vehicle_id: pricing.tenant_vehicle_id,
      applicable: organization)
  end
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json,
      margins: [margin],
      flat_margins: {charge_category.code => 50})
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
  let(:inputs) do
    Struct.new("FeeInputs", :charge_category, :rate_basis, :min_value, :max_value, :measures, :targets)
    Struct::FeeInputs.new(
      charge_category,
      rate_basis,
      min_value,
      max_value,
      measures,
      measures.cargo_units
    )
  end

  describe "it creates a valid Fee object" do
    let!(:fee) { described_class.new(inputs: inputs) }

    it "returns the charge category" do
      expect(fee.charge_category).to eq(charge_category)
    end

    it "returns the target" do
      expect(fee.targets).to eq([cargo_unit])
    end

    it "returns the min value" do
      expect(fee.min_value).to eq(min_value)
    end

    it "returns the breakdowns" do
      expect(fee.breakdowns).to eq(manipulated_result.breakdowns)
    end

    it "returns the pricing_id" do
      expect(fee.pricing_id).to eq(pricing.id)
    end

    it "returns the load_type" do
      expect(fee.load_type).to eq(pricing.load_type)
    end

    it "returns the section" do
      expect(fee.section).to eq("cargo")
    end

    it "returns the cargo_class" do
      expect(fee.cargo_class).to eq(pricing.cargo_class)
    end

    it "returns the validity" do
      expect(fee.validity).to eq(pricing.validity)
    end

    it "returns the flat_margin" do
      expect(fee.flat_margin).to eq(Money.new(5000, max_value.currency))
    end
  end
end
