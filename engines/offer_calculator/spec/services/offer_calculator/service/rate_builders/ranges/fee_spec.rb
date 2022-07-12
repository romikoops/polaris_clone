# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::Ranges::Fee do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:measures) do
    OfferCalculator::Service::Measurements::Request.new(
      request: request,
      scope: scope.with_indifferent_access,
      object: FactoryBot.build(:manipulator_result,
        original: trucking_pricing,
        result: trucking_pricing.as_json,
        breakdowns: breakdowns)
    )
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let(:cargo_class) { "lcl" }
  let(:trucking_pricing) { FactoryBot.create(:trucking_trucking, organization: organization, cargo_class: cargo_class) }
  let!(:trucking_charge_category) do
    FactoryBot.create(:legacy_charge_categories, organization: organization, code: "trucking_#{cargo_class}")
  end
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
  let(:trucking_original_fee) { trucking_pricing.rates.dig("kg", 0, "rate") }
  let(:trucking_component) { trucking_fee.components.first }
  let(:cargo_units) do
    [FactoryBot.create(:journey_cargo_unit,
      width_value: 0.1,
      length_value: 0.1,
      height_value: 0.1,
      weight_value: 100,
      quantity: 1)]
  end
  let(:trucking_fee) { described_class.new(request: request, measure: measures.targets.first, modifier: modifier).fee }
  let(:modifier) { trucking_pricing.rates.keys.first }

  before do
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  describe ".fee" do
    it "returns the correct fee components (trucking rate)", :aggregate_failures do
      expect(trucking_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
      expect(trucking_fee.components.length).to eq(1)
      expect(trucking_component.value).to eq(Money.new(trucking_original_fee["value"] * 100, trucking_original_fee["currency"]))
    end

    it "filters out the non relevant ranges from the breakdowns", :aggregate_failures do
      expect(trucking_fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
      expect(measures.object.breakdowns.select { |breakdown| breakdown.charge_category == trucking_charge_category }
        .flat_map { |breakdown| breakdown.data["kg"].map { |row| row.slice("max_kg", "min_kg") } }
        .uniq).to eq([trucking_pricing.rates.dig("kg", 0).slice("max_kg", "min_kg")])
    end

    context "when the the breakdown has no data" do
      let(:breakdowns) do
        [Pricings::ManipulatorBreakdown.new(
          source: nil,
          delta: 0,
          data: {},
          charge_category: trucking_charge_category
        )]
      end

      it "returns a component successfully" do
        expect(trucking_fee.components.length).to eq(1)
      end
    end

    context "when the the breakdown is not blank but does not have data under the modifier" do
      let(:breakdowns) do
        [Pricings::ManipulatorBreakdown.new(
          source: nil,
          delta: 0,
          data: { "c" => [] },
          charge_category: trucking_charge_category
        )]
      end

      it "returns a component successfully" do
        expect(trucking_fee.components.length).to eq(1)
      end
    end
  end
end
