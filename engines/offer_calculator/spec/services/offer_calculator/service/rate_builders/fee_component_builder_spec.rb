# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::FeeComponentBuilder do
  let(:min_value) { Money.new(1000, "USD") }
  let(:max_value) { Money.new(1e9, "USD") }
  let(:rate_basis) { "PER_WM" }
  let(:target) { nil }
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:charge_category) { pricing.fees.first.charge_category }
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
  let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: pricing,
      result: pricing.as_json,
      margins: [margin])
  end
  let(:measures) do
    OfferCalculator::Service::Measurements::Unit.new(
      cargo: cargo.units.first,
      scope: {},
      object: manipulated_result
    )
  end
  let(:fee) do
    pricing_fee.fee_data.as_json
  end
  let(:target_value) { Money.new(pricing_fee.rate * 100.0, pricing_fee.currency_name) }
  let(:default_base) { OfferCalculator::Service::RateBuilders::FeeComponent::DEFAULT_BASE }
  let(:stowage_fee) do
    {
      "key" => "QDF",
      "max" => nil,
      "min" => 5,
      "name" => "Wharfage / Quay Dues",
      "range" => [{"max" => 5, "min" => 0, "ton" => 41, "currency" => "EUR"}, {"cbm" => 8, "max" => 40, "min" => 6, "currency" => "EUR"}],
      "currency" => "EUR",
      "rate_basis" => "PER_UNIT_TON_CBM_RANGE"
    }
  end
  let(:dynamic_fee) do
    {
      "key" => "QDF",
      "max" => nil,
      "min" => 5,
      "name" => "Wharfage / Quay Dues",
      "cbm" => 10,
      "ton" => 20,
      "currency" => "EUR",
      "rate_basis" => "PER_CBM_TON"
    }
  end

  describe "it creates a valid FeeComponent object" do
    let(:fee_components) do
      described_class.components(
        fee: fee,
        measures: measures
      )
    end

    context "with standard fee type (no base set)" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm, pricing: pricing, base: nil) }

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(target_value)
          expect(fee_components.first.modifier).to eq(:wm)
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end

    context "with standard fee type (base set)" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm, pricing: pricing, base: 200) }

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(target_value)
          expect(fee_components.first.modifier).to eq(:wm)
          expect(fee_components.first.base).to eq(200)
        end
      end
    end

    context "with stowage range fee (ton)" do
      let(:fee) { stowage_fee }

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(Money.new(4100, "EUR"))
          expect(fee_components.first.modifier).to eq(:ton)
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end

    context "with stowage range fee (cbm)" do
      let(:fee) { stowage_fee }

      before do
        allow(measures).to receive(:stowage_factor).and_return(Measured::StowageFactor.new(7, "m3/t"))
      end

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(Money.new(800, "EUR"))
          expect(fee_components.first.modifier).to eq(:cbm)
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end

    context "with stowage range fee (no hits)" do
      let(:fee) { stowage_fee }

      before do
        allow(measures).to receive(:stowage_factor).and_return(Measured::StowageFactor.new(41, "m3/t"))
      end

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(Money.new(0, "EUR"))
          expect(fee_components.first.modifier).to eq(:shipment)
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end

    context "with range flat fee" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm_range_flat, pricing: pricing) }

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(Money.new(1200, "EUR"))
          expect(fee_components.first.modifier).to eq(:shipment)
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end

    context "with range fee" do
      let(:pricing_fee) { FactoryBot.create(:fee_per_wm_range, pricing: pricing) }

      before do
        allow(measures).to receive(:stowage_factor).and_return(Measured::StowageFactor.new(41, "m3/t"))
      end

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(1)
          expect(fee_components.first.value).to eq(Money.new(1200, "EUR"))
          expect(fee_components.first.modifier).to eq(:wm)
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end

    context "with dynamic modifiers" do
      let(:fee) { dynamic_fee }

      it "returns the properly set up Fee Component" do
        aggregate_failures do
          expect(fee_components.length).to eq(2)
          expect(fee_components.map(&:value)).to match_array([Money.new(2000, "EUR"), Money.new(1000, "EUR")])
          expect(fee_components.map(&:modifier)).to match_array(%i[cbm ton])
          expect(fee_components.first.base).to eq(default_base)
        end
      end
    end
  end
end
