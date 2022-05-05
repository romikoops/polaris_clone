# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::BreakdownBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:fee) do
    OfferCalculator::Service::Charges::Fee.new(
      rate: Money.from_amount(150, "USD"),
      charge_category_id: FactoryBot.create(:legacy_charge_categories).id,
      rate_basis: "PER_SHIPMENT",
      base: 0,
      minimum_charge: Money.from_amount(60, "USD"),
      maximum_charge: Money.from_amount(10_050, "USD"),
      range_min: 0,
      range_max: Float::INFINITY,
      surcharge: Money.from_amount(0, "USD"),
      applied_margin: margin,
      parent: parent_fee,
      delta: 50
    )
  end
  let(:parent_fee) do
    OfferCalculator::Service::Charges::Fee.new(
      rate: Money.from_amount(100, "USD"),
      charge_category_id: FactoryBot.create(:legacy_charge_categories).id,
      rate_basis: "PER_SHIPMENT",
      base: 0,
      minimum_charge: Money.from_amount(10, "USD"),
      maximum_charge: Money.from_amount(10_000, "USD"),
      range_min: 0,
      range_max: Float::INFINITY,
      surcharge: Money.from_amount(0, "USD")
    )
  end
  let(:breakdowns) { described_class.new(fee: fee, metadata: { original_id: 1 }).perform }
  let(:margin) { FactoryBot.create(:pricings_margin, applicable: applicable, organization: organization) }
  let(:applicable) { organization }

  describe "#perform" do
    it "returns 1 breakdown for the original Fee and one for every margined Fee that is a descendant", :aggregate_failures do
      expect(breakdowns.map(&:source)).to eq([nil, margin])
      expect(breakdowns.map(&:data)).to eq([parent_fee.to_h, fee.to_h])
      expect(breakdowns.map(&:order)).to eq([0, 1])
    end
  end
end
