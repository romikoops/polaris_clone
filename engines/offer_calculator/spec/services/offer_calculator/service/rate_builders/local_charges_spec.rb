# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::LocalCharges do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:local_charge) { FactoryBot.create(:legacy_local_charge, organization: organization) }
  let(:measures) do
    OfferCalculator::Service::Measurements::Request.new(
      request: request,
      scope: scope.with_indifferent_access,
      object: object
    )
  end
  let(:request) { FactoryBot.build(:offer_calculator_request, organization: organization) }
  let!(:solas_charge_category) { FactoryBot.create(:solas_charge, organization: organization) }
  let!(:qdf_charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization, code: "qdf") }
  let(:solas_fee) { local_charge.fees["SOLAS"] }
  let(:qdf_fee) { local_charge.fees["QDF"] }
  let(:scope) { {} }
  let(:breakdowns) do
    local_charge.fees.map do |key, fee|
      Pricings::ManipulatorBreakdown.new(
        source: nil,
        delta: 0,
        data: fee,
        charge_category: Legacy::ChargeCategory.from_code(organization_id: organization.id, code: key)
      )
    end
  end
  let(:object) {
    FactoryBot.build(:manipulator_result, original: local_charge, result: local_charge.as_json, breakdowns: breakdowns)
  }

  before do
    allow(request).to receive(:cargo_units).and_return(cargo_units)
  end

  describe ".perform" do
    context "with (no consolidation)" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 200,
          width_value: 0.2,
          length_value: 0.2,
          height_value: 0.2,
          quantity: 1)]
      end
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(1)
          expect(fee.charge_category).to eq(solas_charge_category)
        end
      end

      it "returns the correct fee components" do
        aggregate_failures do
          expect(component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(fee.components.length).to eq(1)
          expect(component.value).to eq(Money.new(solas_fee["value"] * 100, solas_fee["currency"]))
        end
      end
    end

    context "with (multiple fees & ranges & no consolidation)" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 200,
          width_value: 0.2,
          length_value: 0.2,
          height_value: 0.2,
          quantity: 1),
          FactoryBot.create(:journey_cargo_unit,
            weight_value: 100,
            width_value: 0.2,
            length_value: 0.2,
            height_value: 0.2,
            quantity: 1)]
      end
      let(:local_charge) { FactoryBot.create(:legacy_local_charge, :multiple_fees, organization: organization) }
      let(:solas_fee_result) { results.find { |f| f.charge_category == solas_charge_category } }
      let(:qdf_fee_result) { results.find { |f| f.charge_category == qdf_charge_category } }
      let(:first_component) { solas_fee_result.components.first }
      let(:second_component) { qdf_fee_result.components.first }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(solas_fee_result).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(4)
          expect(solas_fee_result.charge_category).to eq(solas_charge_category)
        end
      end

      it "returns the correct fee components (first)" do
        aggregate_failures do
          expect(first_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(solas_fee_result.components.length).to eq(1)
          expect(first_component.value).to eq(Money.new(solas_fee["value"] * 100, solas_fee["currency"]))
        end
      end

      it "returns the correct fee components (second)" do
        aggregate_failures do
          expect(results.count { |f| f.charge_category == qdf_charge_category }).to eq(2)
          expect(second_component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(qdf_fee_result.components.length).to eq(1)
          expect(second_component.value).to eq(Money.new(qdf_fee.dig("range", 0, "ton") * 100, qdf_fee["currency"]))
        end
      end
    end

    context "with (consolidation)" do
      let(:cargo_units) do
        [FactoryBot.create(:journey_cargo_unit,
          weight_value: 200,
          width_value: 0.2,
          length_value: 0.2,
          height_value: 0.2,
          quantity: 1),
          FactoryBot.create(:journey_cargo_unit,
            weight_value: 100,
            width_value: 0.2,
            length_value: 0.2,
            height_value: 0.2,
            quantity: 1)]
      end
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let(:scope) { {consolidation: {cargo: {backend: true}}} }
      let!(:results) { described_class.fees(request: request, measures: measures) }

      it "returns the correct fees" do
        aggregate_failures do
          expect(fee).to be_a(OfferCalculator::Service::RateBuilders::Fee)
          expect(results.length).to eq(1)
          expect(fee.charge_category).to eq(solas_charge_category)
        end
      end

      it "returns the correct fee components" do
        aggregate_failures do
          expect(component).to be_a(OfferCalculator::Service::RateBuilders::FeeComponent)
          expect(fee.components.length).to eq(1)
          expect(component.value).to eq(Money.new(solas_fee["value"] * 100, solas_fee["currency"]))
        end
      end
    end
  end
end
