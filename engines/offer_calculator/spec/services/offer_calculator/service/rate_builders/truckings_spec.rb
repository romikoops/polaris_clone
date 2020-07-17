# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Truckings do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: "cargo_item", organization: organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:cbm_ratio) { 250 }
  let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, organization: organization, cbm_ratio: cbm_ratio) }
  let(:cargo) { FactoryBot.create(:cloned_cargo, quotation_id: quotation.id) }
  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, organization: organization) }
  let!(:trucking_lcl_charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization, code: "non_stackable") }
  let(:puf_original_fee) { trucking_pricing.fees["PUF"] }
  let(:trucking_original_fee) { trucking_pricing.rates.dig("kg", 0, "rate") }
  let(:scope) { {} }
  let(:measures) { OfferCalculator::Service::Measurements::Cargo.new(cargo: cargo, scope: scope.with_indifferent_access, object: object) }
  let(:breakdowns) do
    breakdown_array = []
    trucking_pricing.fees.each do |key, fee|
      breakdown_array << Pricings::ManipulatorBreakdown.new(
        source: nil,
        delta: 0,
        data: fee,
        charge_category: Legacy::ChargeCategory.from_code(organization_id: organization.id, code: key)
      )
    end
    breakdown_array << Pricings::ManipulatorBreakdown.new(
      source: nil,
      delta: 0,
      data: trucking_pricing.rates,
      charge_category: trucking_lcl_charge_category
    )
    breakdown_array
  end
  let(:object) { FactoryBot.build(:manipulator_result, original: trucking_pricing, result: trucking_pricing.as_json, breakdowns: breakdowns) }
  let(:puf_fee) { results.find { |f| f.charge_category == puf_charge_category } }
  let(:trucking_fee) { results.find { |f| f.charge_category == trucking_lcl_charge_category } }
  let(:puf_component) { puf_fee.components.first }
  let(:trucking_component) { trucking_fee.components.first }

  describe ".perform" do
    context "with freight pricing (no consolidation)" do
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(puf_fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
          expect(results.map(&:charge_category)).to match_array([puf_charge_category, trucking_lcl_charge_category])
        end
      end

      it "returns the correct fee components (trucking fees)" do
        aggregate_failures do
          expect(puf_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(puf_fee.components.length).to eq(1)
          expect(puf_component.value).to eq(Money.new(puf_original_fee["value"] * 100, puf_original_fee["currency"]))
        end
      end

      it "returns the correct fee components (trucking rate)" do
        aggregate_failures do
          expect(trucking_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(trucking_fee.components.length).to eq(1)
          expect(trucking_component.value).to eq(Money.new(trucking_original_fee["value"] * 100, trucking_original_fee["currency"]))
        end
      end
    end

    context "with hard trucking limit" do
      let(:cargo) do
        FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
          FactoryBot.create(:lcl_unit,
            weight_value: 100_000,
            cargo: tapped_cargo)
        end
      end
      let(:scope) { {hard_trucking_limit: true} }

      it "raises and error when above the limit" do
        expect { described_class.fees(quotation: quotation, measures: measures) }.to raise_error(OfferCalculator::Errors::LoadMeterageExceeded)
      end
    end

    context "without hard trucking limit" do
      let(:cargo) do
        FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
          FactoryBot.create(:lcl_unit,
            weight_value: 100_000,
            cargo: tapped_cargo)
        end
      end
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
          expect(results.map(&:charge_category)).to match_array([puf_charge_category, trucking_lcl_charge_category])
        end
      end
    end

    context "when below range" do
      let(:cargo) do
        FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
          FactoryBot.create(:lcl_unit,
            weight_value: 0.001,
            height_value: 0.001,
            width_value: 0.001,
            length_value: 0.001,
            stackable: true,
            cargo: tapped_cargo)
        end
      end
      let(:cbm_ratio) { 1 }
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end

    context "with unit_in_kg fees" do
      let(:trucking_pricing) { FactoryBot.create(:trucking_with_unit_and_kg, organization: organization) }
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end

    context "with wm fees" do
      let(:trucking_pricing) { FactoryBot.create(:trucking_with_wm_rates, organization: organization) }
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end

    context "with fcl_40 cargo" do
      let(:trucking_pricing) { FactoryBot.create(:fcl_20_unit_trucking, organization: organization) }
      let(:cargo) do
        FactoryBot.create(:cargo_cargo, quotation_id: quotation.id).tap do |tapped_cargo|
          FactoryBot.create(:fcl_20_unit,
            quantity: 2,
            cargo: tapped_cargo)
        end
      end
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

      it "returns fees" do
        aggregate_failures do
          expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(2)
        end
      end
    end
  end
end
