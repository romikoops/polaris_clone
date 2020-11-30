# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Fee do
  let(:min_value) { Money.new(1000, "USD") }
  let(:max_value) { Money.new(1e9, "USD") }
  let(:rate_basis) { "PER_WM" }
  let(:target) { nil }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:charge_category) { pricing.fees.first.charge_category }
  let(:quotation) { FactoryBot.create(:quotations_quotation, organization: organization) }
  let(:cargo) do
    FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
      FactoryBot.create(:cargo_unit, cargo: tapped_cargo)
    end
  end
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
  let(:measures) do
    OfferCalculator::Service::Measurements::Unit.new(
      cargo: cargo.units.first,
      scope: {},
      object: manipulated_result
    )
  end
  let(:inputs) do
    Struct.new("FeeInputs", :charge_category, :rate_basis, :min_value, :max_value, :measures, :target)
    Struct::FeeInputs.new(
      charge_category,
      rate_basis,
      min_value,
      max_value,
      measures,
      cargo.units.first
    )
  end

  describe "it creates a valid Fee object" do
    let!(:fee) { described_class.new(inputs: inputs) }

    it "returns the charge category" do
      expect(fee.charge_category).to eq(charge_category)
    end

    it "returns the target" do
      expect(fee.target).to eq(cargo.units.first)
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
