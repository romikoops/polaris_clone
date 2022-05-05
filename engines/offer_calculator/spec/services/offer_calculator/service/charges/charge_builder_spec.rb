# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::ChargeBuilder do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:pricing) { FactoryBot.create(:lcl_pricing, organization: organization) }
  let(:fee) { pricing.fees.first }
  let(:fee_rows) { [fee_row] }
  let(:fee_row) do
    {
      "cbm_ratio" => 1000.0,
      "tenant_vehicle_id" => pricing.tenant_vehicle_id,
      "margin_type" => "freight_margin",
      "cargo_class" => "lcl",
      "load_type" => "cargo_item",
      "origin_hub_id" => 1,
      "destination_hub_id" => 2,
      "direction" => direction,
      "effective_date" => Time.zone.today,
      "expiration_date" => 2.weeks.from_now.to_date,
      "vm_ratio" => 1.0,
      "context_id" => context_id,
      "rate_basis" => rate_basis,
      "range_min" => 0,
      "range_max" => Float::INFINITY,
      "range_unit" => range_unit,
      "charge_category_id" => fee.charge_category_id,
      "itinerary_id" => 1277,
      "code" => "bas",
      "rate" => 1111.0,
      "base" => 1.0e-06,
      "currency" => "EUR",
      "section" => "cargo",
      "organization_id" => organization.id,
      "load_meterage_ratio" => nil,
      "load_meterage_stackable_type" => nil,
      "load_meterage_non_stackable_type" => nil,
      "load_meterage_hard_limit" => nil,
      "load_meterage_stackable_limit" => nil,
      "load_meterage_non_stackable_limit" => nil,
      "km" => nil,
      "truck_type" => nil,
      "carrier_lock" => false,
      "source_id" => context_id,
      "source_type" => source_type,
      "min" => 1.0,
      "max" => nil
    }
  end
  let(:margin_rows) do
    { "id" => [],
      "rate" => [],
      "operator" => [],
      "code" => [],
      "margin_id" => [],
      "applicable_id" => [],
      "applicable_type" => [],
      "effective_date" => [],
      "expiration_date" => [],
      "origin_hub_id" => [],
      "destination_hub_id" => [],
      "tenant_vehicle_id" => [],
      "pricing_id" => [],
      "cargo_class" => [],
      "margin_type" => [],
      "rank" => [] }
  end
  let(:source_type) { "Pricings::Pricing" }
  let(:context_id) { fee.pricing_id }
  let(:context) do
    instance_double("OfferCalculator::Service::Charges::Context",
      direction: direction,
      origin_hub_id: 1,
      destination_hub_id: 2,
      rate_basis: rate_basis,
      base: 0,
      effective_date: Time.zone.today,
      expiration_date: 2.weeks.from_now.to_date,
      tenant_vehicle_id: pricing.tenant_vehicle_id)
  end
  let(:rate_basis) { "PER_WM" }
  let(:range_unit) { "wm" }
  let(:measured_cargo) { instance_double(OfferCalculator::Service::Measurements::Cargo, scope: {}, object: context) }
  let(:charge) do
    described_class.new(
      fee_rows: Rover::DataFrame.new(fee_rows),
      margin_rows: Rover::DataFrame.new(margin_rows),
      measured_cargo: measured_cargo,
      range_unit: range_unit
    ).perform
  end
  let(:direction) { "export" }

  before do
    allow(measured_cargo).to receive(range_unit.to_sym).and_return(instance_double("MeasuredValue", value: 1))
  end

  describe "#perform" do
    it "returns Charge wrapped around a Fee", :aggregate_failures do
      expect(charge).to be_a(OfferCalculator::Service::Charges::Charge)
      expect(charge.fee).to be_a(OfferCalculator::Service::Charges::Fee)
    end

    context "when there are multiple range_types" do
      let(:fee_rows) { range_data.map { |range_datum| fee_row.merge(range_datum) } }
      let(:range_data) do
        [
          {
            "range_min" => 0,
            "range_max" => 10,
            "range_unit" => "cbm",
            "rate_basis" => "PER_CBM",
            "rate" => 10.0
          },
          {
            "range_min" => 0,
            "range_max" => 2,
            "range_unit" => "ton",
            "rate_basis" => "PER_TON",
            "rate" => 5.0
          }
        ]
      end

      before do
        allow(measured_cargo).to receive(:cbm).and_return(instance_double("Measured::Volume", value: 1))
        allow(measured_cargo).to receive(:ton).and_return(instance_double("Measured::Weight", value: 0.5))
      end

      it "returns the Charge with the highest value" do
        expect(charge.fee.rate_basis).to eq("PER_CBM")
      end
    end
  end
end
