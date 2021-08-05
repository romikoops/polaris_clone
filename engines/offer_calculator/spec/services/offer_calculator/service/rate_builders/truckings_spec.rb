# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Truckings do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:measures) do
    OfferCalculator::Service::Measurements::Request.new(
      request: request,
      scope: scope.with_indifferent_access,
      object: object
    )
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:cbm_ratio) { 250 }
  let(:cargo_class) { "lcl" }
  let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, organization: organization, cargo_class: cargo_class, cbm_ratio: cbm_ratio) }
  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, organization: organization) }
  let!(:trucking_charge_category) do
    FactoryBot.create(:legacy_charge_categories, organization: organization, code: "trucking_#{cargo_class}")
  end
  let(:puf_original_fee) { trucking_pricing.fees["PUF"] }
  let(:trucking_original_fee) { trucking_pricing.rates.dig("kg", 0, "rate") }
  let(:scope) { {} }
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
      charge_category: trucking_charge_category
    )
    breakdown_array
  end
  let(:object) do
    FactoryBot.build(:manipulator_result,
      original: trucking_pricing, result: trucking_pricing.as_json, breakdowns: breakdowns)
  end
  let(:puf_fee) { results.find { |f| f.charge_category == puf_charge_category } }
  let(:trucking_fee) { results.find { |f| f.charge_category == trucking_charge_category } }
  let(:expected_charge_categories) { [puf_charge_category, trucking_charge_category] }
  let(:puf_component) { puf_fee.components.first }
  let(:trucking_component) { trucking_fee.components.first }
  let(:cargo_units) do
    [FactoryBot.create(:journey_cargo_unit,
      width_value: 1.20,
      length_value: 0.80,
      height_value: 1.40,
      weight_value: 100,
      quantity: 1)]
  end
  let(:results) { described_class.fees(request: request, measures: measures) }

  before do
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  describe ".perform" do
    shared_examples_for "building two fees from the trucking object" do
      it "returns the correct fees", :aggregate_failures do
        expect(results.first).to be_a(OfferCalculator::Service::RateBuilders::Fee)
        expect(results.map(&:charge_category)).to match_array(expected_charge_categories)
      end
    end

    context "with freight pricing (no consolidation)" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          width_value: 0.1,
          length_value: 0.1,
          height_value: 0.1,
          weight_value: 100,
          quantity: 1)]
      end

      it_behaves_like "building two fees from the trucking object"

      it "returns the correct fee components (trucking fees)", :aggregate_failures do
        expect(puf_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
        expect(puf_fee.components.length).to eq(1)
        expect(puf_component.value).to eq(Money.new(puf_original_fee["value"] * 100, puf_original_fee["currency"]))
      end

      it "returns the correct fee components (trucking rate)", :aggregate_failures do
        expect(trucking_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
        expect(trucking_fee.components.length).to eq(1)
        expect(trucking_component.value).to eq(Money.new(trucking_original_fee["value"] * 100, trucking_original_fee["currency"]))
      end
    end

    context "with hard trucking limit" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.40,
          weight_value: 100_000,
          quantity: 1)]
      end
      let(:scope) { { hard_trucking_limit: true } }
      let(:journey_error) { Journey::Error.find_by(code: OfferCalculator::Errors::LoadMeterageExceeded.new.code) }

      it "creates a Journey::Error and raises and error when above the limit" do
        expect { described_class.fees(request: request, measures: measures) }.to raise_error(OfferCalculator::Errors::LoadMeterageExceeded)
        expect(journey_error).to be_present
      end
    end

    context "with hard trucking limit and multiple ranges (one above range)" do
      let(:trucking_pricing) do
        FactoryBot.create(:trucking_trucking, :unit_in_kg, organization: organization, cbm_ratio: cbm_ratio, fees: {})
      end
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 2100,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.40,
          quantity: 1)]
      end
      let(:scope) { { hard_trucking_limit: true }.with_indifferent_access }
      let(:expected_charge_categories) { [trucking_charge_category] }

      it_behaves_like "building two fees from the trucking object"
    end

    context "without hard trucking limit" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 100_000,
          width_value: 1.20,
          length_value: 0.80,
          height_value: 1.40,
          quantity: 1)]
      end

      it_behaves_like "building two fees from the trucking object"
    end

    context "when below range" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 0.001,
          height_value: 0.001,
          width_value: 0.001,
          length_value: 0.001,
          quantity: 1)]
      end
      let(:cbm_ratio) { 1 }

      it_behaves_like "building two fees from the trucking object"
    end

    context "when between range an error is raised" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 250,
          height_value: 0.001,
          width_value: 0.001,
          length_value: 0.001,
          quantity: 1)]
      end
      let(:cbm_ratio) { 1 }
      let(:trucking_pricing) do
        FactoryBot.create(:trucking_trucking, rates: {
          kg: [
            {
              rate: { base: 100.0, value: 237.5, currency: "SEK", rate_basis: "PER_X_KG" },
              max_kg: "200.0",
              min_kg: "0.1",
              min_value: 400.0
            },
            {
              rate: { base: 100.0, value: 237.5, currency: "SEK", rate_basis: "PER_X_KG" },
              max_kg: "1000.0",
              min_kg: "300.0",
              min_value: 400.0
            }
          ]
        },
                                              organization: organization)
      end

      it "raises the TruckingRateNotFound error" do
        expect { described_class.fees(request: request, measures: measures) }.to raise_error(OfferCalculator::Errors::TruckingRateNotFound)
      end
    end

    context "with unit_in_kg fees" do
      let(:trucking_pricing) { FactoryBot.create(:trucking_with_unit_in_kg, organization: organization) }

      it_behaves_like "building two fees from the trucking object"
    end

    context "with wm fees" do
      let(:trucking_pricing) { FactoryBot.create(:trucking_with_wm_rates, organization: organization) }

      it_behaves_like "building two fees from the trucking object"
    end

    context "with fcl_20 cargo" do
      let(:cargo_class) { "fcl_20" }
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          cargo_class: cargo_class,
          quantity: 2)]
      end

      it_behaves_like "building two fees from the trucking object"
    end
  end
end
