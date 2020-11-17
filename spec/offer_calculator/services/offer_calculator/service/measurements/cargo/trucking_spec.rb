# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Measurements::Cargo do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }
  let(:trucking_location) { FactoryBot.create(:trucking_location, :distance, data: distance) }
  let(:distance) { 15 }
  let(:trucking_pricing) do
    FactoryBot.create(:trucking_trucking,
      organization: organization,
      load_meterage: load_meterage,
      cbm_ratio: cbm_ratio,
      location: trucking_location)
  end
  let(:manipulated_result) do
    FactoryBot.build(:manipulator_result,
      original: trucking_pricing,
      result: trucking_pricing.as_json)
  end
  let(:scope) { {} }
  let(:target_cargo) { cargo }
  let(:cbm_ratio) { 250 }
  let(:load_meterage) { {} }
  let(:measure) do
    described_class.new(
      cargo: target_cargo,
      scope: scope.with_indifferent_access,
      object: manipulated_result
    )
  end

  describe "when asking for chargeeable weight" do
    context "without load_meterage" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          weight_value: 1000,
          height_value: 1,
          width_value: 1,
          length_value: 1,
          stackable: true)
      end

      it "returns the payload weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(1000)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.km.value).to eq(15)
        end
      end
    end

    context "with scope consolidation.trucking.calculation" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 1,
          weight_value: 200,
          height_value: 1.4,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 2,
          weight_value: 400,
          height_value: 1.5,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
      end

      let(:scope) { {consolidation: {trucking: {calculation: true}}} }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(1056)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(true)
        end
      end
    end

    context "with  scope consolidation.trucking.comparative" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 45,
          weight_value: 30.0 / 45.0,
          height_value: 0.15,
          width_value: 0.1,
          length_value: 0.2,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 15,
          weight_value: 36.0 / 15.0,
          height_value: 0.25,
          width_value: 0.3,
          length_value: 0.3,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 32,
          weight_value: 168.0 / 32.0,
          height_value: 0.2,
          width_value: 0.25,
          length_value: 0.25,
          stackable: true)
      end

      let(:scope) { {'consolidation': {'trucking': {'comparative': true}}} }
      let(:load_meterage) { {ratio: 1000, ldm_limit: 48_000, stacking: true} }
      let(:cbm_ratio) { 200 }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(234.015)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(true)
        end
      end

      it "calculates the correct area" do
        aggregate_failures do
          expect(measure.area_for_load_meters).to eq(0.4275)
        end
      end
    end

    context "with  scope consolidation.trucking.comparative" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 45,
          weight_value: 30.0 / 45.0,
          height_value: 0.15,
          width_value: 0.1,
          length_value: 0.2,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 15,
          weight_value: 36.0 / 15.0,
          height_value: 0.25,
          width_value: 0.3,
          length_value: 0.3,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 32,
          weight_value: 168.0 / 32.0,
          height_value: 0.2,
          width_value: 0.25,
          length_value: 0.25,
          stackable: true)
      end

      let(:scope) { {'consolidation': {'trucking': {'comparative': true}}} }
      let(:load_meterage) { {ratio: 1000, ldm_limit: 48_000, stacking: false} }
      let(:cbm_ratio) { 200 }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(234.015)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(true)
        end
      end

      it "calculates the correct area" do
        aggregate_failures do
          expect(measure.area_for_load_meters).to eq(4.25)
        end
      end
    end

    context "with scope consolidation.trucking.comparative (non-stackable)" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 45,
          weight_value: 30.0 / 45.0,
          height_value: 0.15,
          width_value: 0.1,
          length_value: 0.2,
          stackable: false)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 15,
          weight_value: 36.0 / 15.0,
          height_value: 0.25,
          width_value: 0.3,
          length_value: 0.25,
          stackable: false)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 32,
          weight_value: 168.0 / 32.0,
          height_value: 0.2,
          width_value: 0.25,
          length_value: 0.25,
          stackable: false)
      end

      let(:scope) { {'consolidation': {'trucking': {'comparative': true}}} }
      let(:load_meterage) { {ratio: 1000, lm_limit: 0.5} }
      let(:cbm_ratio) { 200 }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value.to_i).to eq(1677)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(false)
        end
      end

      it "calculates the correct area" do
        aggregate_failures do
          expect(measure.area_for_load_meters).to eq(4.025)
        end
      end
    end

    context "with scope consolidation.trucking.calculation with agg cargo" do
      before do
        FactoryBot.create(:aggregated_unit,
          cargo: cargo,
          quantity: 1,
          weight_value: 3000,
          volume_value: 1.5,
          stackable: true)
      end

      let(:scope) { {'consolidation': {'trucking': {'calculation': true}}} }
      let(:load_meterage) { {ratio: 1000, lm_limit: 0.5} }
      let(:cbm_ratio) { 250 }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(3000)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(true)
        end
      end
    end

    context "with scope consolidation.trucking.load_meterage_only" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 1,
          weight_value: 200,
          height_value: 1.4,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 2,
          weight_value: 400,
          height_value: 1.5,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
      end

      let(:scope) { {'consolidation': {'trucking': {'load_meterage_only': true}}} }
      let(:load_meterage) {}
      let(:cbm_ratio) { 250 }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(1136)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(true)
        end
      end
    end

    context "with consolidation.trucking.load_meterage_only (low limit)" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 1,
          weight_value: 200,
          height_value: 1.4,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 2,
          weight_value: 400,
          height_value: 1.5,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
      end

      let(:scope) { {'consolidation': {'trucking': {'load_meterage_only': true}}} }
      let(:load_meterage) { {area_limit: 0.5, ratio: 1000} }
      let(:cbm_ratio) { 250 }

      it "returns the correct weight" do
        aggregate_failures do
          expect(measure.kg.value).to eq(1200)
          expect(measure.kg.unit.name).to eq("kg")
          expect(measure.stackability).to eq(false)
        end
      end
    end

    context "with hard load meterage limit" do
      before do
        FactoryBot.create(:lcl_unit,
          cargo: cargo,
          quantity: 1,
          weight_value: 200,
          height_value: 1.4,
          width_value: 1.2,
          length_value: 0.8,
          stackable: true)
      end

      let(:scope) { {'consolidation': {'trucking': {'load_meterage_only': true}}} }
      let(:load_meterage) { {area_limit: 0.005, ratio: 1000, hard_limit: true} }
      let(:cbm_ratio) { 250 }

      it "returns the correct weight" do
        aggregate_failures do
          expect { measure.kg }.to raise_error { OfferCalculator::Errors::LoadMeterageExceeded }
        end
      end
    end
  end
end
