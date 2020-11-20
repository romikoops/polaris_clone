# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::RateBuilders::LocalCharges do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:shipment) { FactoryBot.create(:legacy_shipment, load_type: "cargo_item", organization: organization) }
  let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }
  let(:local_charge) { FactoryBot.create(:legacy_local_charge, organization: organization) }
  let(:cargo) { FactoryBot.create(:cloned_cargo, quotation_id: quotation.id) }
  let!(:solas_charge_category) { FactoryBot.create(:solas_charge, organization: organization) }
  let!(:qdf_charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization, code: "qdf") }
  let(:solas_fee) { local_charge.fees["SOLAS"] }
  let(:qdf_fee) { local_charge.fees["QDF"] }
  let(:scope) { {} }
  let(:measures) { OfferCalculator::Service::Measurements::Cargo.new(cargo: cargo, scope: scope, object: object) }
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

  describe ".perform" do
    context "with (no consolidation)" do
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

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
      before do
        FactoryBot.create(:legacy_cargo_item, shipment: shipment, payload_in_kg: 100)
        shipment.cargo_items.reload
      end

      let(:local_charge) { FactoryBot.create(:legacy_local_charge, :multiple_fees, organization: organization) }
      let(:solas_fee_result) { results.find { |f| f.charge_category == solas_charge_category } }
      let(:qdf_fee_result) { results.find { |f| f.charge_category == qdf_charge_category } }
      let(:first_component) { solas_fee_result.components.first }
      let(:second_component) { qdf_fee_result.components.first }
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

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
      let(:fee) { results.first }
      let(:component) { fee.components.first }
      let(:scope) { {consolidation: {cargo: {backend: true}}} }
      let!(:results) { described_class.fees(quotation: quotation, measures: measures) }

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
