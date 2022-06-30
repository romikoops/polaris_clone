# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Charge do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:rate_basis) { "PER_SHIPMENT" }
  let(:measure) { 1.0 }
  let(:fee) do
    OfferCalculator::Service::Charges::Fee.new(
      rate: Money.from_amount(100, "USD"),
      charge_category_id: FactoryBot.create(:legacy_charge_categories).id,
      rate_basis: rate_basis,
      base: base,
      minimum_charge: Money.from_amount(10, "USD"),
      maximum_charge: Money.from_amount(10_000, "USD"),
      range_min: 0,
      measure: measure,
      range_max: Float::INFINITY,
      range_unit: "shipment",
      surcharge: Money.from_amount(0, "USD")
    )
  end
  let(:charge) do
    described_class.new(
      fee: fee,
      measured_cargo: measured_cargo
    )
  end
  let(:measured_cargo) do
    instance_double("OfferCalculator::Service::MeasuredCargo",
      object: context_double,
      chargeable_weight_in_tons: Measured::Weight(2, "t"),
      volume: Measured::Volume.new(0.5, "m3"))
  end
  let(:direction) { "export" }
  let(:base) { 0 }
  let(:context_double) do
    instance_double("OfferCalculator::Service::Charges::Context",
      context_id: "aaaa-bbbb-cccc-dddd",
      direction: direction,
      origin_hub_id: 1,
      destination_hub_id: 2,
      effective_date: Time.zone.today,
      expiration_date: 2.weeks.from_now.to_date)
  end

  before { Organizations.current_id = organization.id }

  describe "#value" do
    context "when it is a PER_SHIPMENT fee and the value lies within the limits" do
      let(:rate_basis) { "PER_SHIPMENT" }
      let(:measure) { 1.0 }

      it "returns the value of the rate as a Money object" do
        expect(charge.value).to eq(fee.rate)
      end
    end

    context "when it is a PER_KG fee and the value lies within the limits" do
      let(:rate_basis) { "PER_KG" }
      let(:measure) { 10.0 }

      it "returns the value of the rate as a Money object" do
        expect(charge.value).to eq(fee.rate * measure)
      end
    end

    context "when it is a PER_KG fee and the value lies beyond the maximum_charge" do
      let(:rate_basis) { "PER_KG" }
      let(:measure) { 1000.0 }

      it "returns the value of the rate as the maximum_charge" do
        expect(charge.value).to eq(fee.maximum_charge)
      end
    end

    context "when it is a PER_KG fee and the value lies below the minimum_charge" do
      let(:rate_basis) { "PER_KG" }
      let(:measure) { 0.001 }

      it "returns the value of the rate as the minimum_charge" do
        expect(charge.value).to eq(fee.minimum_charge)
      end
    end

    context "when it is a PER_KG fee and the base is 10" do
      let(:rate_basis) { "PER_KG" }
      let(:measure) { 95.0 }
      let(:base) { 10.0 }

      it "returns the value of the rate as the stepped by the base, rounded up" do
        expect(charge.value).to eq(fee.rate * 10)
      end
    end

    context "when it is a PERCENTAGE fee" do
      let(:rate_basis) { "PERCENTAGE" }
      let(:measure) { 2.0 }

      it "returns a Money object of zero value" do
        expect(charge.value).to eq(Money.new(0, fee.currency))
      end
    end
  end

  describe "#grouping_values" do
    it "returns the context_id and validity values as an array for grouping purposes" do
      expect(charge.grouping_values).to eq([context_double.context_id, context_double.effective_date, context_double.expiration_date])
    end
  end
end
