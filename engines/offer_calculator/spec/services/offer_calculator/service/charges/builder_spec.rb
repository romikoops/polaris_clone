# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Builder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:query) { FactoryBot.create(:journey_query, client: user, organization: organization, cargo_count: 0) }
  let(:request) { FactoryBot.build(:offer_calculator_request, client: user, organization: organization, query: query) }
  let(:period) { Range.new(Time.zone.today, 2.weeks.from_now.to_date) }
  let(:charges) { described_class.new(request: request, relation: relation, period: period).perform }
  let(:cargo) { request.cargo_units.first }
  let(:charge) { charges.first }

  before { Organizations.current_id = organization.id }

  context "when building Pricing charges" do
    let(:relation) { Pricings::Pricing.where(organization: organization) }
    let(:pricing) { FactoryBot.create(:pricings_pricing, organization: organization) }

    context "with a PER_WM fee" do
      let!(:fee) { FactoryBot.create(:pricings_fee, :per_wm, pricing: pricing, organization: organization) }

      it "returns Charges::Charge objects for the BAS fee", :aggregate_failures do
        expect(charge.code).to eq(fee.charge_category.code)
        expect(charge.measure).to eq(charge.measured_cargo.wm.value)
      end
    end

    context "with a PER_KG_RANGE fee" do
      let!(:fee) { FactoryBot.create(:pricings_fee, :per_kg_range, pricing: pricing, organization: organization) }

      it "returns Charges::Charge objects for the BAS fee", :aggregate_failures do
        expect(charge.code).to eq(fee.charge_category.code)
        expect(charge.measure).to eq(charge.measured_cargo.kg.value)
      end
    end

    context "with a PER_UNIT_TON_CBM_RANGE fee" do
      let!(:fee) { FactoryBot.create(:pricings_fee, :per_unit_ton_cbm_range, pricing: pricing, organization: organization) }

      it "returns Charges::Charge objects for the BAS fee", :aggregate_failures do
        expect(charge.code).to eq(fee.charge_category.code)
        expect(charge.measure).to eq(charge.measured_cargo.cbm.value)
      end
    end

    context "with a PER_WM fee and a percentage Margin whose effective date ends halfway during the period" do
      let!(:fee) { FactoryBot.create(:pricings_fee, :per_shipment, pricing: pricing, organization: organization) }
      let!(:margin) { FactoryBot.create(:pricings_margin, expiration_date: 1.week.from_now, value: 0.1, organization: organization, applicable: user) }

      expected_validities = [
        Range.new(Time.zone.today, 1.week.from_now.to_date, exclude_end: true),
        Range.new(1.week.from_now.to_date, 2.weeks.from_now.to_date, exclude_end: true)
      ]

      it "returns a Charge object for each time frame, one with Margin applied, one without", :aggregate_failures do
        expect(charges.map(&:code)).to match_array([fee.charge_category.code] * 2)
        expect(charges.map { |charg| Range.new(charg.effective_date, charg.expiration_date, exclude_end: true) }).to match_array(expected_validities)
        expect(charges.first.value).to eq(Money.from_amount(fee.rate * (1 + margin.value.to_d), fee.currency_name) * charge.fee.measure)
        expect(charges.last.value).to eq(Money.from_amount(fee.rate, fee.currency_name) * charge.fee.measure)
      end
    end

    context "with a Margin whose fee code does not exist in the query frame, percentage margin version, multiple pricings available" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:margin_b) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:pricing) { FactoryBot.create(:pricings_pricing, cargo_class: "fcl_20", organization: organization) }
      let(:query) { FactoryBot.create(:journey_query, load_type: :fcl, client: user, organization: organization, cargo_count: 0) }

      before do
        %w[fcl_20 fcl_40 fcl_40_hq].each do |cargo_class|
          FactoryBot.create(:journey_cargo_unit, :fcl, query: query, cargo_class: cargo_class)
        end
        query.reload
        FactoryBot.create(:fcl_40_pricing, organization: organization)
        FactoryBot.create(:fcl_40_hq_pricing, organization: organization)
        FactoryBot.create(:pricings_fee, :per_kg, pricing: pricing, organization: organization)
        FactoryBot.create(:pricings_fee, :per_shipment,
          charge_category: FactoryBot.create(:baf_charge, organization: organization),
          pricing: pricing,
          organization: organization)
        FactoryBot.create(:pricings_detail,
          margin: margin,
          organization: organization,
          charge_category: FactoryBot.create(:legacy_charge_categories, code: "vat", organization: organization))
      end

      it "returns a Charge object for the margin", :aggregate_failures do
        expect(charges.map(&:code)).to match_array(%w[bas bas bas baf vat vat vat])
        expect(charges.map(&:cargo_class)).to match_array(%w[fcl_40 fcl_40_hq fcl_20 fcl_40 fcl_40_hq fcl_20 fcl_20])
      end
    end

    context "with a Margin whose fee code does not exist in the query frame, flat margin version" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }

      before do
        FactoryBot.create(:pricings_fee, :per_kg, pricing: pricing, organization: organization)
        FactoryBot.create(:pricings_detail,
          margin: margin,
          operator: "+",
          value: 100,
          organization: organization,
          charge_category: FactoryBot.create(:legacy_charge_categories, code: "vat", organization: organization))
      end

      it "returns a Charge object for the margin", :aggregate_failures do
        charge = charges.find { |charg| charg.code == "vat" }
        expect(charge.rate_basis).to eq("PER_SHIPMENT")
        expect(charge.value).to eq(Money.new(100 * 100.0, organization.scope.default_currency))
      end
    end

    context "with a Margin whose fee code does not exist in the query frame, additive margin version" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }

      before do
        FactoryBot.create(:pricings_fee, :per_kg, pricing: pricing, organization: organization)
        FactoryBot.create(:pricings_detail,
          margin: margin,
          operator: "&",
          value: 100,
          organization: organization,
          charge_category: FactoryBot.create(:legacy_charge_categories, code: "vat", organization: organization))
      end

      it "returns a Charge object for the margin", :aggregate_failures do
        charge = charges.find { |charg| charg.code == "vat" }
        expect(charge.rate_basis).to eq("PER_UNIT")
        expect(charge.value).to eq(Money.new(100 * 100.0, organization.scope.default_currency))
      end
    end
  end

  context "when the relation is LocalCharges" do
    let(:relation) { Legacy::LocalCharge.where(id: local_charge) }

    context "with a PER_SHIPMENT fee" do
      let(:local_charge) { FactoryBot.create(:legacy_local_charge, organization: organization) }

      it "returns Charges::Charge objects for the SOLAS fee", :aggregate_failures do
        expect(charge.code).to eq("solas")
        expect(charge.measure).to eq(1)
      end
    end

    context "with a PER_UNIT_TON_CBM_RANGE fee" do
      let(:local_charge) { FactoryBot.create(:legacy_local_charge, :range, organization: organization) }

      it "returns Charges::Charge objects for the QDF fee", :aggregate_failures do
        expect(charge.code).to eq("qdf")
        expect(charge.measure).to eq(charge.measured_cargo.stowage_factor.value)
      end
    end
  end

  context "when the relation is Trucking::Trucking" do
    let(:relation) { Trucking::Trucking.where(id: trucking) }

    before { FactoryBot.create(:charge_category, organization: organization, code: "trucking_lcl") }

    context "when the trucking has no extra fees attached, kg based ranges and PER_SHIPMENT rate basis" do
      let(:trucking) { FactoryBot.create(:trucking_trucking, fees: {}, organization: organization) }

      it "returns Charges::Charge objects for the Trucking fee", :aggregate_failures do
        expect(charge.code).to eq("trucking_lcl")
        expect(charge.measure).to eq(charge.measured_cargo.kg.value)
        expect(charge.fee.range_min).to eq(500.0)
        expect(charge.fee.range_max).to eq(600.0)
      end
    end

    context "when the trucking has no extra fees attached, cbm and kg based ranges and PER_SHIPMENT rate basis" do
      let(:trucking) { FactoryBot.create(:trucking_trucking, :cbm_kg_rates, fees: {}, organization: organization) }
      let(:kg_component) { charge.components.find { |com| com.range_unit == "kg" } }
      let(:cbm_component) { charge.components.find { |com| com.range_unit == "cbm" } }

      it "returns Charges::Charge objects for each option that hits the range (KG provides a larger value)", :aggregate_failures do
        expect(charge.code).to eq("trucking_lcl")
        expect(charge.measure).to eq(charge.measured_cargo.kg.value)
        expect(charge.fee.range_min).to eq(500.0)
        expect(charge.fee.range_max).to eq(1000.0)
      end
    end
  end
end
