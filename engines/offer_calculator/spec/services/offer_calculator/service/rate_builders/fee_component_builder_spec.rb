# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::FeeComponentBuilder do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json,
      margins: [FactoryBot.create(:pricings_margin,
        organization: organization,
        tenant_vehicle_id: pricing.tenant_vehicle_id,
        applicable: organization)])
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Cargo.new(
      scope: {},
      object: manipulated_result,
      engine: FactoryBot.create(:measurements_engine_unit,
        scope: {},
        manipulated_result: manipulated_result,
        cargo_unit: FactoryBot.create(:journey_cargo_unit,
          cargo_class: "lcl",
          weight_value: 1000,
          height_value: 1,
          width_value: 1,
          length_value: 1,
          quantity: 1,
          stackable: true))
    )
  end
  let(:fee) { pricing_fee.fee_data.as_json }
  let(:target_value) { Money.new(pricing_fee.rate * 100.0, pricing_fee.currency_name) }
  let(:fee_components) { described_class.components(fee: fee, measures: measures) }
  let(:default_base) { 0 }

  describe "it creates a valid FeeComponent object" do
    context "with standard fee type (no base set)" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm, pricing: pricing, base: nil) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(target_value)
        expect(fee_components.first.modifier).to eq(:wm)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with standard fee type (base set)" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm, pricing: pricing, base: 200) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(target_value)
        expect(fee_components.first.modifier).to eq(:wm)
        expect(fee_components.first.base).to eq(200)
      end
    end

    context "with rate under attribute key (ton)" do
      let(:fee) { FactoryBot.build(:component_builder_fee, :ton) }
      let(:target_value) { Money.new(fee[:ton] * 100.0, fee[:currency]) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(target_value)
        expect(fee_components.first.modifier).to eq(:ton)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with percentage fee type " do
      let(:fee) { FactoryBot.build(:component_builder_fee, :percentage) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(0, "USD"))
        expect(fee_components.first.percentage).to eq(0.325)
        expect(fee_components.first.modifier).to eq(:percentage)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with the reformatted percentage fee type " do
      let(:fee) { FactoryBot.build(:component_builder_fee, :rate_percentage) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(0, "USD"))
        expect(fee_components.first.percentage).to eq(0.325)
        expect(fee_components.first.modifier).to eq(:percentage)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with stowage range fee (ton)" do
      let(:fee) { FactoryBot.build(:component_builder_fee, :stowage) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(4100, "EUR"))
        expect(fee_components.first.modifier).to eq(:ton)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with stowage range fee (cbm)" do
      let(:fee) { FactoryBot.build(:component_builder_fee, :stowage) }

      before do
        allow(measures).to receive(:stowage_factor).and_return(Measured::StowageFactor.new(7, "m3/t"))
      end

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(800, "EUR"))
        expect(fee_components.first.modifier).to eq(:cbm)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with stowage range fee (no hits)" do
      let(:fee) { FactoryBot.build(:component_builder_fee, :stowage) }

      before do
        allow(measures).to receive(:stowage_factor).and_return(Measured::StowageFactor.new(41, "m3/t"))
      end

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(0, "EUR"))
        expect(fee_components.first.modifier).to eq(:shipment)
        expect(fee_components.first.base).to eq(default_base)
      end
    end

    context "with range flat fee" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm_range_flat, pricing: pricing) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(800, "EUR"))
        expect(fee_components.first.modifier).to eq(:shipment)
        expect(fee_components.first.base).to eq(pricing_fee.base)
      end
    end

    context "with range fee" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm_range, pricing: pricing) }

      before do
        allow(measures).to receive(:stowage_factor).and_return(Measured::StowageFactor.new(41, "m3/t"))
      end

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(1)
        expect(fee_components.first.value).to eq(Money.new(800, "EUR"))
        expect(fee_components.first.modifier).to eq(:wm)
        expect(fee_components.first.base).to eq(pricing_fee.base)
      end
    end

    context "with dynamic modifiers" do
      let(:fee) { FactoryBot.build(:component_builder_fee, :dynamic) }

      it "returns the properly set up Fee Component", :aggregate_failures do
        expect(fee_components.length).to eq(2)
        expect(fee_components.map(&:value)).to match_array([Money.new(2000, "EUR"), Money.new(1000, "EUR")])
        expect(fee_components.map(&:modifier)).to match_array(%i[cbm ton])
        expect(fee_components.first.base).to eq(default_base)
      end
    end
  end
end
